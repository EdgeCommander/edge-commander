defmodule EdgeCommander.Util do
  require Record
  require Logger
  import EdgeCommander.Accounts, only: [current_user: 1, by_api_keys: 2]
  import Plug.Conn
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText,    Record.extract(:xmlText,    from_lib: "xmerl/include/xmerl.hrl")
  alias EdgeCommander.Activity.Logs
  alias EdgeCommander.Repo

  def convert_into_string(value) do
    value |> Kernel.inspect()
  end

  def convert_string_float(data) do
    data
    |> String.split( "MB")
    |> List.first
    |> String.replace(",", "")
    |> String.trim
    |> String.to_float()
  end

  def parse_changeset(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn
      {msg, opts} -> String.replace(msg, "%{count}", to_string(opts[:count]))
      msg -> msg
    end)
  end

  def parse_inner_array(text) do
    text
    |> String.to_charlist
    |> :xmerl_scan.string
  end

  def parse_single_element({ xml, _ }, node) do
    case :xmerl_xpath.string(node, xml) do
      [element] ->
        [text] = xmlElement(element, :content)
        xmlText(text, :value) |> to_string
      [] -> ""
    end
  end

  def port_open?(address, port) do
    case :gen_tcp.connect(to_charlist(address), port, [:binary, active: false], 1000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        true
      {:error, _error} ->
        false
    end
  end

  def shift_zone(timestamp, timezone \\ "Europe/Dublin") do
    %{year: year, month: month, day: day, hour: hour, minute: minute, second: second} = timestamp
    Calendar.DateTime.from_erl!({{year, month, day}, {hour, minute, second}}, "UTC")
    |> Calendar.DateTime.shift_zone(timezone)
    |> case do
      {:ok, datetime} -> datetime |> DateTime.to_naive
      {:ambiguous, datetime} -> datetime.possible_date_times |> hd |> DateTime.to_naive
    end
  end

  def get_user_id(conn, params) do
    api_key = params["api_key"]
    api_id = params["api_id"]

    if api_key == nil or api_id == nil do
      current_user = current_user(conn)
      current_user.id
    else
      users = by_api_keys(api_id, api_key)
      users.id
    end
  end
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("")

  def string_generator(length) do
    Enum.reduce((1..length), [], fn (_i, acc) ->
      [Enum.random(@chars) | acc]
    end) |> Enum.join("")
  end

  def user_request_ip(conn) do
    ip = case get_req_header(conn, "x-forwarded-for") do
       [proxy_ip] -> proxy_ip |> first_ip |> valid_ip
       _ -> conn.remote_ip |> Tuple.to_list |> Enum.join(".") |> valid_ip
    end
    ip
  end

  defp first_ip(ips) do
    case String.split(ips, ",") do
      [ip] -> ip
      [ip, _proxy_ip] -> ip
    end
  end

  defp valid_ip(ip) do
    re = ~r/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
    case Regex.match?(re, ip) do
      true -> ip
      false -> nil
    end
  end

  def get_country_from_geoip(ip) do
    case GeoIP.lookup(ip) do
      {:ok, info} -> %{ip: ip, country: Map.get(info, :country_name), country_code: Map.get(info, :country_code)}
      _ -> %{ip: ip, country: "", country_code: ""}
    end
  end

  def get_user_agent(conn) do
    case get_req_header(conn, "user-agent") do
      [] -> ""
      [user_agent|_rest] -> parse_user_agent(user_agent)
    end
  end

  defp parse_user_agent(nil), do: ""
  defp parse_user_agent(user_agent), do: user_agent

  def create_log(conn, params) do
    ip = user_request_ip(conn)
    location_details = get_country_from_geoip(ip)
    browser = get_user_agent(conn) |> Browser.name() 
    platform = get_user_agent(conn) |> Browser.platform()  |> Atom.to_string()

    params = %{
      "browser" => browser,
      "platform" => platform,
      "ip" => location_details[:ip],
      "country" => location_details[:country],
      "country_code" => location_details[:country_code],
      "event" => params["event"],
      "user_id" => params["user_id"]
    }
    changeset = Logs.changeset(%Logs{}, params)
    case Repo.insert(changeset) do
      {:ok, _logs} ->
        conn
        |> put_status(:created)
      
      {:error, changeset} ->
        errors = parse_changeset(changeset)
        _traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
    end
  end

  def condition_for_sms_alert(%{variable: variable} = params) when variable == "less_than", do: sms_less_than(params)
  def condition_for_sms_alert(%{variable: variable} = params) when variable == "less_than_equal_to", do: sms_less_than_equal_to(params)
  def condition_for_sms_alert(%{variable: variable} = params) when variable == "greater_than", do: sms_greater_than(params)
  def condition_for_sms_alert(%{variable: variable} = params) when variable == "greater_than_equal_to", do: sms_greater_than_equal_to(params)
  def condition_for_sms_alert(%{variable: variable} = params) when variable == "equals_to", do: sms_equals_to(params)

  defp sms_less_than(%{total_sms: total_sms, value: value} = params) when total_sms < value  do
    send_sms_alert_email(params)
  end
  defp sms_less_than(_params), do: :noop

  defp sms_less_than_equal_to(%{total_sms: total_sms, value: value} = params) when total_sms <= value  do
    send_sms_alert_email(params)
  end
  defp sms_less_than_equal_to(_params), do: :noop

  defp sms_greater_than(%{total_sms: total_sms, value: value} = params) when total_sms > value  do
    send_sms_alert_email(params)
  end
  defp sms_greater_than(_params), do: :noop

  defp sms_greater_than_equal_to(%{total_sms: total_sms, value: value} = params) when total_sms >= value  do
    send_sms_alert_email(params)
  end
  defp sms_greater_than_equal_to(_params), do: :noop

  defp sms_equals_to(%{total_sms: total_sms, value: value} = params) when total_sms == value  do
    send_sms_alert_email(params)
  end
  defp sms_equals_to(_params), do: :noop

  defp send_sms_alert_email(params) do
    alert_for = params.alert_for
    ensure_and_send_alert(alert_for, params)
  end

  defp get_variable("less_than"), do: "<"
  defp get_variable("less_than_equal_to"), do: "<="
  defp get_variable("greater_than"), do: ">"
  defp get_variable("greater_than_equal_to"), do: ">="
  defp get_variable("equals_to"), do: "=="

  defp ensure_and_send_alert("monthly_sms_alert", %{number: number, total_sms: total_sms, variable: variable, value: value, last_bill_date: bill_date} = _params) do
    last_bill_date = convert_date_format(bill_date)
    EdgeCommander.Commands.get_monthly_sms_usage_rules(variable, value)
    |> Enum.map(fn(recipients) ->
      variable = variable |> get_variable
      # EdgeCommander.EcMailer.monthly_sms_usage_alert(last_bill_date, recipients, number, total_sms, variable, value)
      Logger.info "Monthly SMS usage email alert has been sent."
    end)
  end

  defp ensure_and_send_alert("daily_sms_alert", %{number: number, total_sms: total_sms, variable: variable, value: value} = _params) do
    current_day_date = get_current_date()
    current_date = convert_date_format(current_day_date)
    EdgeCommander.Commands.get_active_sms_usage_rules(variable, value)
    |> Enum.map(fn(recipients) ->
      variable = variable |> get_variable
      # EdgeCommander.EcMailer.daily_sms_usage_alert(current_date, recipients, number, total_sms, variable, value)
      Logger.info "Daily SMS usage email alert has been sent."
    end)
  end

  defp ensure_and_send_alert("battery_voltage_alert", %{total_sms: total_volt, variable: variable, value: value} = _params) do
    EdgeCommander.Commands.get_battery_voltages_rules(variable, value)
    |> Enum.map(fn(recipients) ->
      variable = variable |> get_variable
      # EdgeCommander.EcMailer.battery_voltage_alert(recipients, total_volt, variable, value)
      Logger.info "Battery voltage alert has been sent."
    end)
  end

  def convert_date_format(date) do
    year = date.year
    month = date.month |> ensure_number
    day = date.day |> ensure_number
    "#{day}-#{month}-#{year}"
  end

  def date_time_to_string(nil), do: "-"
  def date_time_to_string("-"), do: "-"
  def date_time_to_string(date) do
    year = date.year
    month = date.month |> ensure_number
    day = date.day |> ensure_number
    hour = date.hour |> ensure_number
    minute = date.minute |> ensure_number
    second = date.second |> ensure_number
    "#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}"
  end

  def date_to_string(nil), do: "-"
  def date_to_string("-"), do: "-"
  def date_to_string(date) do
    year = date.year
    month = date.month |> ensure_number
    day = date.day |> ensure_number
    "#{year}-#{month}-#{day}"
  end

  def get_current_date() do
    current_year = DateTime.utc_now |> Map.fetch!(:year)
    month = DateTime.utc_now |> Map.fetch!(:month)
    day = DateTime.utc_now |> Map.fetch!(:day)
    current_month = ensure_number(month)
    current_day = ensure_number(day)
    date_time = "#{current_year}-#{current_month}-#{current_day} 00:00:00"
    {:ok, date} = NaiveDateTime.from_iso8601(date_time)
    date
  end

  def ensure_number(number) when number >= 1 and number <= 9, do: "0#{number}"
  def ensure_number(number), do: number
end
