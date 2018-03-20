defmodule ThreeScraper.SIM do
  alias ThreeScraper.{API, SIM, Cookie}
  require Logger

  defstruct [
    :name,
    :number,
    :addon,
    :allowance,
    :volume_used,
    :datetime
  ]

  def get_info do
    for sim <- get_sims() do
      get_sim_data(sim)
    end
  end

  def get_sims do
    %{body: body} = retry(fn -> API.get("/NASApp/MyAccount/PostpaidManageDataUsageServlet.htm") end, 10)
    extract_sims(body)
  end

  def get_sim_data(%SIM{number: sim_number} = sim) do
    post_form = [{"ctn", sim_number}]
    %{body: body} = retry(fn ->
      API.post("/NASApp/MyAccount/PostpaidManageDataUsageServlet.htm", {:form, post_form})
    end, 10)

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
      |> set_used_value

    %{sim | addon: addon,
            allowance: allowance,
            volume_used: volume_used,
            datetime: NaiveDateTime.utc_now()}
  end

  def ensure_three_trs(trs) do
    length(trs)
    |> assert_trs(trs)
  end

  def assert_trs(4, trs), do: trs
  def assert_trs(3, trs), do: trs
  def assert_trs(2, trs), do: trs
  def assert_trs(1, trs) do
    new_trs = trs ++ [{"tr", [], [{"td", [], ["NIL"]}, {"td", [], ["NIL"]}, {"td", [], ["NIL"]}]}]
    new_trs
  end

  def extract_sims(body) do
    body
    |> Floki.parse()
    |> Floki.find("#ctn")
    |> Floki.find("option")
    |> Enum.map(fn {"option", props, [name]} ->
      number = :proplists.get_value("value", props)
      name = extract_sim_name(name)
      %SIM{number: number, name: name}
    end)
  end

  def extract_sim_name(name) do
    name
    |> String.split("\t", trim: true)
    |> List.last()
    |> String.trim()
  end

  def retry(_fun, attempts_left) when attempts_left <= 0 do
    raise("retry failed")
  end
  def retry(fun, attempts_left) do
    case fun.() do
      {:ok, %{status_code: 200} = resp} -> resp
      {:ok, %{status_code: 302}} ->
        Logger.error("cookie expired")
        Cookie.update()
        retry(fun, attempts_left - 1)
      error ->
        Logger.error([to_string(__MODULE__), ?\n, inspect(error)])
        retry(fun, attempts_left - 1)
    end
  end

  defp set_addon_value("NIL"), do: "NIL"
  defp set_addon_value(addon) do
    if is_binary(addon) == true  do
        addon_value = addon
      else
        {"b", _, [addon_value]}  =  addon
    end
    addon_value
  end
  defp set_allowance_value("Unlimited"), do: -1
  defp set_allowance_value(allowance), do: allowance

  defp set_used_value("NIL"), do: "NIL"
  defp set_used_value(volume_used), do: volume_used

end
