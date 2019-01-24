defmodule ThreeScraper.Scraper do
  import Ecto.Query, warn: false
  import EdgeCommander.ThreeScraper.ThreeUsers, only: [users_list: 0, get_three_account!: 1]
  import EdgeCommander.Nexmo, only: [get_last_message_details: 1, get_sms_count: 2]
  alias EdgeCommander.Repo
  alias ThreeScraper.Scraper
  alias EdgeCommander.ThreeScraper.SimLogs
  alias EdgeCommander.ThreeScraper.Sims
  alias EdgeCommander.ThreeScraper.Records
  alias EdgeCommander.Util
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
      bill_day = user.bill_day

      update_bill_days(three_user_id, bill_day)

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

      old_data = number |> number_with_code |> Records.last_record_for_number_by_user(user_id)

      old_record_list = old_data |> ensure_old_record

      if (old_record_list == new_record_list) == false do
      sims_logs = %{
        number: number |> number_with_code,
        name: name,
        addon: new_addon,
        allowance: new_allowance,
        volume_used: new_volume_used,
        datetime: datetime,
        sim_provider: "Three Ireland",
        user_id: user_id,
        three_user_id: three_user_id
      }

      changeset = SimLogs.changeset(%SimLogs{}, sims_logs)
      case Repo.insert(changeset) do
        {:ok, _logs} ->
          Logger.info "Inserting SIM data for #{number}"
          save_sim_to_db(sims_logs)
        {:error, _changeset} ->
          Logger.error "Inserting SIM data failed for #{number}"
        end
        else
          Logger.info "Data matched for #{number}"
        end
    end)
  end

  def save_sim_to_db(params) do
    number = params[:number]
    sims_records = Records.get_single_sim(number)
    volume_usage = Records.get_yesterday_usage(number)
    yesterday_volume_used = volume_usage |> ensure_yesterday_volume

    allowance_in_number = params[:allowance] |> Util.convert_string_float
    current_in_number = params[:volume_used] |> Util.convert_string_float
    yesterday_in_number = yesterday_volume_used |> Util.convert_string_float

    percentage_used = get_percentage_used(current_in_number, allowance_in_number)
    remaning_days = get_remaing_days(current_in_number, allowance_in_number, yesterday_in_number)

    bill_records = Records.get_sim_bill_day(number)
    last_bill_date = get_bill_date(bill_records.bill_day)
    last_sms_records = last_sms_details(number)
    sms_since_last_bill = get_total_sms(number, last_bill_date)

    params = %{
      number: params[:number],
      name: params[:name],
      addon: params[:addon],
      allowance: params[:allowance],
      volume_used: params[:volume_used],
      sim_provider: params[:sim_provider],
      yesterday_volume_used: yesterday_volume_used,
      percentage_used: percentage_used,
      remaning_days: remaning_days,
      last_log_reading_at: params[:datetime] |> Util.shift_zone(),
      last_bill_date: last_bill_date |> Util.date_to_string,
      last_sms: last_sms_records.last_sms,
      last_sms_date: last_sms_records.last_sms_date |> Util.date_time_to_string,
      sms_since_last_bill: sms_since_last_bill,
      status: "Not found",
      user_id: params[:user_id],
      three_user_id: params[:three_user_id]
    }

    number_already_exist(sims_records, params)
  end

  def update_bill_days(three_user_id, bill_day) do
    last_bill_date = get_bill_date(bill_day)
    numbers = Records.numbers_by_three_user_id(three_user_id)
    Enum.each(numbers, fn(sim) ->
      sms_since_last_bill = get_total_sms(sim.number, last_bill_date)
      params = %{
        last_bill_date: last_bill_date |> Util.date_to_string,
        sms_since_last_bill: sms_since_last_bill
      }
      Records.get_sim!(sim.id)
      |> Sims.changeset(params)
      |> Repo.update
      |> case do
        {:ok, _sim} ->
          Logger.info "Last bill date & SMS count has been updated for this number #{sim.number}"
        {:error, _changeset} ->
           Logger.info "Last bill date & SMS count did't update for this number #{sim.number}"
      end
    end)
  end

  def get_remaing_days(-1.0, _allowance_in_number, _yesterday_in_number), do: "Infinity"
  def get_remaing_days(0, _allowance_in_number, _yesterday_in_number), do: "Infinity"
  def get_remaing_days(current_in_number, allowance_in_number, yesterday_in_number)  do
    days_left = (allowance_in_number - current_in_number) / (current_in_number - yesterday_in_number)
    val = (days_left / 100) * 100
    val |> Util.convert_into_string
  end

  def get_percentage_used(current_in_number, allowance_in_number) when allowance_in_number > 0  do
    (current_in_number / allowance_in_number * 100) |> Float.round(3)
  end
  def get_percentage_used(_current_in_number, _allowance_in_number), do: -1.0

  def get_bill_date(nil), do: nil
  def get_bill_date("null"), do: nil
  def get_bill_date(day) do
    bill_day = check_data_type(day)
    current_day = DateTime.utc_now |> Map.fetch!(:day)
    current_year = DateTime.utc_now |> Map.fetch!(:year)
    current_month = DateTime.utc_now |> Map.fetch!(:month) |> Util.ensure_number
    bill_day_in_string = bill_day |> Util.ensure_number
    params = %{
      bill_day: bill_day,
      current_day: current_day,
      current_year: current_year,
      current_month: current_month,
      bill_day_in_string: bill_day_in_string
    }
    get_full_date(params)
  end

  defp get_full_date(%{bill_day: bill_day, current_day: current_day} = params) when bill_day > current_day  do
    date_in_string = "#{params.current_year}-#{params.current_month}-#{params.bill_day_in_string}"
    {:ok, date} = Date.from_iso8601(date_in_string)
    native_date = Util.previous_month(date)
    year = native_date |> Map.fetch!(:year)
    month = native_date |> Map.fetch!(:month) |> Util.ensure_number
    date_time = "#{year}-#{month}-#{params.bill_day_in_string} 00:00:00"
    {:ok, date} = NaiveDateTime.from_iso8601(date_time)
    date
  end

  defp get_full_date(%{bill_day: bill_day, current_day: current_day} = params) when bill_day <= current_day  do
    date_time = "#{params.current_year}-#{params.current_month}-#{params.bill_day_in_string} 00:00:00"
    {:ok, date} = NaiveDateTime.from_iso8601(date_time)
    date
  end

  defp check_data_type(number) when is_bitstring(number) do
    {day, ""} = Integer.parse(number)
    day
  end
  defp check_data_type(day), do: day

  def last_sms_details(number) do
    last_sms_details = get_last_message_details(number)
    last_sms = get_last_sms(last_sms_details)
    last_sms_date = get_last_sms_date(last_sms_details)
     %{
      last_sms: last_sms,
      last_sms_date: last_sms_date
    }
  end

  defp get_last_sms_date(nil), do: "-"
  defp get_last_sms_date(last_sms_details), do: last_sms_details |> Map.get(:inserted_at) |> Util.shift_zone()

  defp get_last_sms(nil), do: "-"
  defp get_last_sms(last_sms_details), do: last_sms_details |> Map.get(:text)

  def get_total_sms(_number, "-"), do: 0
  def get_total_sms(number, last_bill_date), do: get_sms_count(number, last_bill_date)

  def number_already_exist(nil, params) do
    changeset = Sims.changeset(%Sims{}, params)
    case Repo.insert(changeset) do
    {:ok, _logs} ->
      Logger.info "SIM number has been saved"
    {:error, _changeset} ->
      Logger.error "SIM number did not saved due to failure."
    end
  end

  def number_already_exist(already_exist, params) do
    id = already_exist.id
    Records.get_sim!(id)
    |> Sims.changeset(params)
    |> Repo.update
    |> case do
      {:ok, _sim} ->
        Logger.info "SIM number has been updated"
      {:error, _changeset} ->
        Logger.error "SIM number did not updated due to failure."
    end
  end

  def ensure_yesterday_volume(nil), do: "-1.0"
  def ensure_yesterday_volume(volume_usage), do: volume_usage[:yesterday_volume_used]

  def get_info(cookie) do
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
      ctn: sim_number
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

  defp ensure_allowance_value(-1), do: "-1.0"
  defp ensure_allowance_value(allowance), do: allowance

  defp ensure_used_value("-"), do: "-1.0"
  defp ensure_used_value(volume_used), do: volume_used

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