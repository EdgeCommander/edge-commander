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

        voltage = get_column_value(data, 13, "V\t")
        params = %{
          "pid" => get_column_value(data, 10, "PID\t"),
          "fw" => get_column_value(data, 3, "FW\t"),
          "serial_no" => get_column_value(data, 12, "SER#\t"),
          "voltage" => voltage,
          "i_value" => get_column_value(data, 7, "I\t"),
          "vpv_value" => get_column_value(data, 14, "VPV\t"),
          "ppv_value" => get_column_value(data, 11, "PPV\t"),
          "cs_value" => get_column_value(data, 1, "CS\t"),
          "err_value" => get_column_value(data, 2, "ERR\t"),
          "h19_value" => get_column_value(data, 4, "H19\t"),
          "h20_value" => get_column_value(data, 5, "H20\t"),
          "h21_value" => get_column_value(data, 6, "H21\t"),
          "h22_value" => 0,
          "h23_value" => 0,
          "datetime" => Enum.at(data, 0)
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
end