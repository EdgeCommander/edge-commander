defmodule EdgeCommanderWeb.BatteryReadingController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Solar.Reading
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import EdgeCommander.Solar, only: [get_readings: 3, list_active_batteries: 0]
  import Ecto.Query, warn: false
  require Logger

  def get_all_batteries() do
    list_active_batteries()
    |> Enum.each(fn(data) ->
      battery_id = data.id
      source_url = data.source_url
      save_status_data(battery_id, source_url)
    end)
  end

  defp save_status_data(battery_id, url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data =
          String.split(body, "\n")
          |> Enum.sort(&(&2 > &1))
          |> Enum.drop_while(fn(x) -> x == "" end)

        pid_record = element_value_and_remainng_data(data, "PID")
        pid = pid_record.value
        data = pid_record.remain_data

        fw_record = element_value_and_remainng_data(data, "FW")
        fw = fw_record.value
        data = fw_record.remain_data

        sr_record = element_value_and_remainng_data(data, "SER#")
        serial_no = sr_record.value
        data = sr_record.remain_data

        i_record = element_value_and_remainng_data(data, "I")
        i_value = i_record.value
        data = i_record.remain_data

        vpv_record = element_value_and_remainng_data(data, "VPV")
        vpv_value = vpv_record.value
        data = vpv_record.remain_data

        ppv_record = element_value_and_remainng_data(data, "PPV")
        ppv_value = ppv_record.value
        data = ppv_record.remain_data

        cs_record = element_value_and_remainng_data(data, "CS")
        cs_value = cs_record.value
        data = cs_record.remain_data

        err_record = element_value_and_remainng_data(data, "ERR")
        err_value = err_record.value
        data = err_record.remain_data

        h19_record = element_value_and_remainng_data(data, "H19")
        h19_value = h19_record.value
        data = h19_record.remain_data

        h20_record = element_value_and_remainng_data(data, "H20")
        h20_value = h20_record.value
        data = h20_record.remain_data

        h21_record = element_value_and_remainng_data(data, "H21")
        h21_value = h21_record.value
        data = h21_record.remain_data

        h22_record = element_value_and_remainng_data(data, "H22")
        h22_value = h22_record.value
        data = h22_record.remain_data

        h23_record = element_value_and_remainng_data(data, "H23")
        h23_value = h23_record.value
        data = h23_record.remain_data

        mppt_record = element_value_and_remainng_data(data, "MPPT")
        mppt_value = mppt_record.value
        data = mppt_record.remain_data

        il_record = element_value_and_remainng_data(data, "IL")
        il_value = il_record.value
        data = il_record.remain_data

        load_record = element_value_and_remainng_data(data, "LOAD")
        load_value = load_record.value
        data = load_record.remain_data

        voltage_record = element_value_and_remainng_data(data, "V")
        voltage = voltage_record.value |> get_numric_value_only
        data = voltage_record.remain_data

        date_record = element_value_and_remainng_data(data, ":")
        datetime = date_record.value

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
          "battery_id" => battery_id,
          "il_value" => il_value,
          "mppt_value" => mppt_value,
          "load_value" => load_value
        }

        save_battery_readings(voltage, params)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.info "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error reason
    end
  end

  defp save_battery_readings("0", _params), do: Logger.error "Battery voltage is zero did not save."
  defp save_battery_readings(_, params) do
    changeset = Reading.changeset(%Reading{}, params)
    case Repo.insert(changeset) do
    {:ok, _data} ->
      Logger.info "Battery status has been saved."
      voltage = params["voltage"]
      ensure_voltage_value(voltage)
    {:error, _changeset} ->
      Logger.error "Battery status did not save."
    end
  end

  def get_battery_record(conn, params)  do
    from_date = params["from_date"]
    to_date = params["to_date"]
    battery_id = params["battery_id"]
    records =
      get_readings(from_date, to_date, battery_id)
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
        records: records
      })
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

  defp get_column_value(string, ":"),  do: string
  defp get_column_value(string, column) do
    [_, value] = String.split(string, column)
    value |> String.trim()
  end

  defp get_numric_value_only(string) do
    string |> String.replace(~r/[^\d]/, "")
  end

end