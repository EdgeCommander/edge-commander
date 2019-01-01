defmodule EdgeCommanderWeb.BatteryController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Solar.Battery
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import EdgeCommander.Solar, only: [list_battery: 0, list_battery_records: 2]
  import Ecto.Query, warn: false
  require Logger

  def save_status_data() do
    url = "http://lidlnewbridgebox2.ddns.net/battery.html"
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data =
          String.split(body, "\n")
          |> Enum.sort(&(&2 > &1))
          |> Enum.drop_while(fn(x) -> x == "" end)

        pid_record = element_value_and_remainng_data(data, "PID\t")
        pid = pid_record.value
        data = pid_record.remain_data

        fw_record = element_value_and_remainng_data(data, "FW\t")
        fw = fw_record.value
        data = fw_record.remain_data

        sr_record = element_value_and_remainng_data(data, "SER#\t")
        serial_no = sr_record.value
        data = sr_record.remain_data

        i_record = element_value_and_remainng_data(data, "I\t")
        i_value = i_record.value
        data = i_record.remain_data

        vpv_record = element_value_and_remainng_data(data, "VPV\t")
        vpv_value = vpv_record.value
        data = vpv_record.remain_data

        ppv_record = element_value_and_remainng_data(data, "PPV\t")
        ppv_value = ppv_record.value
        data = ppv_record.remain_data

        cs_record = element_value_and_remainng_data(data, "CS\t")
        cs_value = cs_record.value
        data = cs_record.remain_data

        err_record = element_value_and_remainng_data(data, "ERR\t")
        err_value = err_record.value
        data = err_record.remain_data

        h19_record = element_value_and_remainng_data(data, "H19\t")
        h19_value = h19_record.value
        data = h19_record.remain_data

        h20_record = element_value_and_remainng_data(data, "H20\t")
        h20_value = h20_record.value
        data = h20_record.remain_data

        h21_record = element_value_and_remainng_data(data, "H21\t")
        h21_value = h21_record.value
        data = h21_record.remain_data

        h22_record = element_value_and_remainng_data(data, "H22\t")
        h22_value = h22_record.value
        data = h22_record.remain_data

        h23_record = element_value_and_remainng_data(data, "H23\t")
        h23_value = h23_record.value
        data = h23_record.remain_data

        voltage_record = element_value_and_remainng_data(data, "V\t")
        voltage = voltage_record.value
        data = voltage_record.remain_data

        date_record = element_value_and_remainng_data(data, ":")
        datetime = date_record.value
        data = date_record.remain_data

        params = %{
          "pid" => pid,
          "fw" => fw,
          "serial_no" => serial_no,
          "voltage" => voltage,
          "i_value" => i_value,
          "vpv_value" => vpv_value,
          "ppv_value" => ppv_value,
          "cs_value" => cs_value,
          "err_value" => err_value,
          "h19_value" => h19_value,
          "h20_value" => h20_value,
          "h21_value" => h21_value,
          "h22_value" => h22_value,
          "h23_value" => h23_value,
          "datetime" => datetime,
        }

        changeset = Battery.changeset(%Battery{}, params)
        case Repo.insert(changeset) do
        {:ok, _data} ->
          Logger.info "Battery status has been saved."
          ensure_voltage_value(voltage)
        {:error, _changeset} ->
          Logger.error "Battery status did not save."
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.info "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error reason
    end
  end

  def get_battery_record(conn, params)  do
    from_date = params["from_date"]
    to_date = params["to_date"]
    records =
      list_battery_records(from_date, to_date)
      |> Enum.map(fn(data) ->
        %{
          id: data.id,
          voltage: data.voltage,
          datetime: data.datetime,
          serial_no: data.serial_no,
          i_value: data.i_value,
          vpv_value: data.vpv_value,
          ppv_value: data.ppv_value,
          cs_value: data.cs_value,
          err_value: data.err_value,
          h19_value: data.h19_value,
          h20_value: data.h20_value,
          h21_value: data.h21_value,
          h22_value: data.h22_value,
          h23_value: data.h23_value
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        "records": records
      })
  end

  defp get_column_value(data, index, column) do
    string = Enum.at(data, index)
    [_, value] = String.split(string, column)
    value |> String.trim()
  end

  defp ensure_voltage_value(value) do
    voltage =
      Decimal.new(value)
      |> Decimal.to_integer
    value_in_volt = voltage / 1000
    voltage_rules = EdgeCommander.Commands.get_battery_voltages_rule_list()
    Enum.each(voltage_rules, fn(rule) ->
      variable = rule.variable
      value = rule.value
      params = %{
        total_sms: value_in_volt,
        variable: variable,
        value: value,
        alert_for: "battery_voltage_alert"
      }
      Util.condition_for_sms_alert(params)
     end)
  end

  defp send_voltage_alert_email(volt) when volt < 12  do
    EdgeCommander.Commands.get_battery_voltages_rules()
    |> Enum.map(fn(recipients) ->
      EdgeCommander.EcMailer.battery_voltage_alert(recipients, volt)
      Logger.info "Email has been sent."
    end)
  end
  defp send_voltage_alert_email(volt), do: :noop

  defp element_value_and_remainng_data(list_data, column) do
    value =
      list_data
      |> Enum.map(fn(element) ->
        existence = element =~ column
        check_element_existence(existence, element)
      end)
      |> Enum.sort(&(&2 > &1))
      |> Enum.drop_while(fn(x) -> x == "" end)

    column_value = List.first(value) |> is_list_empty(column)

    remain_data = list_data |> Enum.reject(fn(x) -> x == column_value end)

    %{
      value: column_value |> get_column_value(column),
      remain_data: remain_data
    }
  end

  defp check_element_existence(true, element), do: element
  defp check_element_existence(false, _element), do: ""

  defp is_list_empty(nil, column), do: "#{column}0"
  defp is_list_empty(value, _column), do: value

  defp get_column_value(string, column) do
    if column != ":" do
      [_, value] = String.split(string, column)
      else
        value = string
    end
    value |> String.trim()
  end
end