defmodule ThreeScraper.Scraper do
  import Ecto.Query, warn: false
  import EdgeCommander.ThreeScraper.ThreeUsers, only: [users_list: 0, get_three_account!: 1]
  alias EdgeCommander.Repo
  alias ThreeScraper.Scraper
  alias EdgeCommander.ThreeScraper.SimLogs
  alias EdgeCommander.ThreeScraper
  require Logger
  use GenServer

  @url "https://login.three.ie"
  @base_url "https://www.three.ie"
  @period 6 * 60 * 60 * 1000 # 6 hour

  defstruct [
    :name,
    :number,
    :addon,
    :allowance,
    :volume_used,
    :datetime
  ]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    Process.send_after(self(), :start, 10 * 1000) # ten seconds
    {:ok, nil}
  end

  def handle_info(:start, state) do
     start_scraper()
     Process.send_after(self(), :start, @period)
    {:noreply, state}
  end

  def start_scraper do
    Logger.info "Scraper is running for all accounts."
    users = users_list()
    Enum.each(users, fn(user) ->
      username = user.username
      password = user.password
      user_id = user.user_id
      three_user_id = user.id
      headers = get_login(username, password)
      cookie = headers |> get_cookies
      cookie |> insert_into_db(user_id, three_user_id)
    end)
  end

  def single_start_scraper(id) do
    Logger.info "Scraper is running for single account."
    user = get_three_account!(id)
    username = user.username
    password = user.password
    user_id = user.user_id
    three_user_id = user.id
    headers = get_login(username, password)
    cookie = headers |> get_cookies
    cookie |> insert_into_db(user_id, three_user_id)
  end

  defp get_login(username, password) do
    login_form = [{"username", username}, {"password", password}, {"section", "section"}]
    case HTTPoison.post(@url, {:form, login_form}, [], hackney: [recv_timeout: 30_000]) do
      {:ok, %HTTPoison.Response{headers: headers}} ->
        headers
      error ->
        Logger.error(["[cookie]", ?\n, inspect(error)])
        get_login(username, password)
    end
  end

  defp get_cookies(headers) do
    cookies = :hackney.cookies(headers)
    case :proplists.get_value("ObSSOCookie", cookies) do
      [cookie | _cookie_opts] -> cookie
      :undefined -> false
    end
  end

  defp insert_into_db(false, _user_id, _three_user_id), do: Logger.error "Login failed."
  defp insert_into_db(cookie, user_id, three_user_id) do
    Logger.info "Getting sims data"
    sim_data =
      get_info(cookie)
      |> Enum.map(&Map.from_struct/1)
      |> Enum.filter(fn(s_sim) -> s_sim.addon != "NIL" end)

    Enum.each(sim_data, fn(log) ->
      addon = log.addon
      allowance = log.allowance
      name = log.name
      number = log.number
      datetime = log.datetime
      volume_used = log.volume_used

      new_addon = addon |> ensure_addon_value
      new_allowance = allowance  |> ensure_allowance_value
      new_volume_used = volume_used  |> ensure_used_value
      new_record_list = [new_addon, new_allowance, new_volume_used, name]

      old_data = number |> number_with_code |> ThreeScraper.last_record_for_number_by_user(user_id)

      old_record_list = old_data |> ensure_old_record

      if (old_record_list == new_record_list) == false do
      sims_logs = %{
        number: number |> number_with_code,
        name: name,
        addon: new_addon,
        allowance: new_allowance |> Float.to_string ,
        volume_used: new_volume_used  |> Float.to_string,
        datetime: datetime,
        sim_provider: "Three Ireland",
        user_id: user_id,
        three_user_id: three_user_id
      }

      changeset = SimLogs.changeset(%SimLogs{}, sims_logs)
      case Repo.insert(changeset) do
        {:ok, _logs} ->
          Logger.info "Inserting SIM data for #{number}"
        {:error, _changeset} ->
          Logger.error "Inserting SIM data failed for #{number}"
        end
        else
          Logger.info "Data matched for #{number}"
        end
    end)
  end

  defp get_info(cookie) do
    for sim <- get_sims(cookie) do
      get_sim_data(sim, cookie)
    end
  end

  defp get_sims(cookie) do
    %{body: body} = HTTPoison.get!(@base_url <> "/NASApp/MyAccount/PostpaidManageDataUsageServlet.htm", %{}, [hackney: [cookie: cookie, recv_timeout: 30_000]])
    extract_sims(body)
  end

  defp get_sim_data(%Scraper{number: sim_number} = sim, cookie) do
    url = @base_url <> "/NASApp/MyAccount/PostpaidManageDataUsageServlet.htm"
    body = Poison.encode!(%{
      "ctn": sim_number
    })
    headers = [{"Content-type", "application/json"}]

    case HTTPoison.post(url, body, headers, [hackney: [cookie: cookie, recv_timeout: 30_000]]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        [_header | internet_usage_row] =
        body
          |> Floki.parse()
          |> Floki.find(".standardMyAccTable")
          |> Floki.find("tr")
          |> ensure_three_trs

        internet_usage = Enum.at(internet_usage_row, -1)

        [{"td", _, [addon]}, {"td", _, [allowance]}, {"td", _, [volume_used]}] =
        Floki.find(internet_usage, "td")

        addon = addon |> set_addon_value
        allowance =
          allowance
          |> String.replace("\n", "") |> String.replace("\t", "")
          |> set_allowance_value

        volume_used =
          volume_used
          |> String.replace("\n", "") |> String.replace("\t", "")

          %{sim | addon: addon,
                allowance: allowance,
                volume_used: volume_used,
                datetime: NaiveDateTime.utc_now()}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(reason)
    end
  end

  defp extract_sims(body) do
    body
    |> Floki.parse()
    |> Floki.find("#ctn")
    |> Floki.find("option")
    |> Enum.map(fn {"option", props, [name]} ->
      number = :proplists.get_value("value", props)
      name = extract_sim_name(name)
      %Scraper{number: number, name: name}
    end)
  end

  defp extract_sim_name(name) do
    name
    |> String.split("\t", trim: true)
    |> List.last()
    |> String.trim()
  end

  defp ensure_three_trs(trs) do
    length(trs)
    |> assert_trs(trs)
  end

  defp assert_trs(4, trs), do: trs
  defp assert_trs(3, trs), do: trs
  defp assert_trs(2, trs), do: trs
  defp assert_trs(1, trs) do
    new_trs = trs ++ [{"tr", [], [{"td", [], ["AYCE"]}, {"td", [], ["Unlimited"]}, {"td", [], ["-"]}]}]
    new_trs
  end

  defp set_addon_value(addon) do
    if is_binary(addon) == true  do
      addon
    else
      {"b", _, [addon_value]}  =  addon
      addon_value
    end
  end

  defp set_allowance_value("Unlimited"), do: -1
  defp set_allowance_value(allowance), do: allowance

  defp number_with_code("0" <> number), do: "+353#{number}"

  defp ensure_allowance_value(-1), do: -1.0
  defp ensure_allowance_value(allowance) do
    {new_allowance, _} = allowance  |> String.replace(",", "") |> Float.parse()
     new_allowance
  end

  defp ensure_used_value("-"), do: 0.0
  defp ensure_used_value(volume_used) do
    {new_volume_used, _} = volume_used  |> String.replace(",", "") |> Float.parse()
    new_volume_used
  end

  defp ensure_addon_value(addon) do
    if is_binary(addon) == true  do
        addon
      else
        {new_addon, _} = addon |> String.replace(",", "") |> Float.parse()
        new_addon
    end
  end

  defp ensure_old_record(nil), do: [nil, nil, nil, nil]
  defp ensure_old_record(old_data) do
    old_addon = old_data.addon  |> ensure_addon_value
    old_allowance = old_data.allowance  |> ensure_allowance_value
    old_volume_used = old_data.volume_used  |> ensure_used_value
    old_name = old_data.name
    [old_addon, old_allowance, old_volume_used, old_name]
  end
end