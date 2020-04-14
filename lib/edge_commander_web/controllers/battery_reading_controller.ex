defmodule EdgeCommanderWeb.BatteryReadingController do
  use EdgeCommanderWeb, :controller
  use PhoenixSwagger
  alias EdgeCommander.Solar.Reading
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import EdgeCommander.Solar, only: [list_active_batteries: 0, get_last_reading: 1, get_readings: 3]
  import Ecto.Query, warn: false
  require Logger

  swagger_path :get_all_readings_by_battery do
    get "/v1/batteries/{id}/readings"
    summary "Returns battery readings by ID"
    parameters do
      id :path, :string, "battery id to read", required: true
      from :query, :string, "Date (YYYY-MM-DD)", required: true
      to :query, :string, "Date (YYYY-MM-DD)", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "batteries"
    response 200, "Success"
  end

  def get_all_batteries() do
    list_active_batteries()
    |> Enum.each(fn(data) ->
      params = %{
        battery_id: data.id,
        url: data.source_url,
        name: data.name,
      }
      save_status_data(params)
    end)
  end

  defp save_status_data(battery_params) do
    battery_id = battery_params[:battery_id]
    url = battery_params[:url]
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

        h1_record = element_value_and_remainng_data(data, "H1")
        h1_value = h1_record.value
        data = h1_record.remain_data

        h2_record = element_value_and_remainng_data(data, "H2")
        h2_value = h2_record.value
        data = h2_record.remain_data

        h3_record = element_value_and_remainng_data(data, "H3")
        h3_value = h3_record.value
        data = h3_record.remain_data

        h4_record = element_value_and_remainng_data(data, "H4")
        h4_value = h4_record.value
        data = h4_record.remain_data

        h5_record = element_value_and_remainng_data(data, "H5")
        h5_value = h5_record.value
        data = h5_record.remain_data

        h6_record = element_value_and_remainng_data(data, "H6")
        h6_value = h6_record.value
        data = h6_record.remain_data

        h7_record = element_value_and_remainng_data(data, "H7")
        h7_value = h7_record.value
        data = h7_record.remain_data

        h8_record = element_value_and_remainng_data(data, "H8")
        h8_value = h8_record.value
        data = h8_record.remain_data

        h9_record = element_value_and_remainng_data(data, "H9")
        h9_value = h9_record.value
        data = h9_record.remain_data

        h10_record = element_value_and_remainng_data(data, "H10")
        h10_value = h10_record.value
        data = h10_record.remain_data

        h11_record = element_value_and_remainng_data(data, "H11")
        h11_value = h11_record.value
        data = h11_record.remain_data

        p_value_record = element_value_and_remainng_data(data, "P")
        p_value = p_value_record.value
        data = p_value_record.remain_data

        ce_value_record = element_value_and_remainng_data(data, "CE")
        consumed_amphours = ce_value_record.value
        data = ce_value_record.remain_data

        soc_value_record = element_value_and_remainng_data(data, "SOC")
        soc_value = soc_value_record.value
        data = soc_value_record.remain_data

        ttg_value_record = element_value_and_remainng_data(data, "TTG")
        time_to_go = ttg_value_record.value
        data = ttg_value_record.remain_data

        alarm_record = element_value_and_remainng_data(data, "Alarm")
        alarm = alarm_record.value
        data = alarm_record.remain_data

        relay_record = element_value_and_remainng_data(data, "Relay")
        relay = relay_record.value
        data = relay_record.remain_data

        ar_record = element_value_and_remainng_data(data, "AR")
        ar_value = ar_record.value
        data = ar_record.remain_data

        bmv_record = element_value_and_remainng_data(data, "BMV")
        bmv_value = bmv_record.value
        data = bmv_record.remain_data

        mv_record = element_value_and_remainng_data(data, "MV")
        data = mv_record.remain_data

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
          "h1_value" => h1_value,
          "h2_value" => h2_value,
          "h3_value" => h3_value,
          "h4_value" => h4_value,
          "h5_value" => h5_value,
          "h6_value" => h6_value,
          "h7_value" => h7_value,
          "h8_value" => h8_value,
          "h9_value" => h9_value,
          "h10_value" => h10_value,
          "h11_value" => h11_value,
          "h19_value" => h19_value,
          "h20_value" => h20_value,
          "h21_value" => h21_value,
          "h22_value" => h22_value,
          "h23_value" => h23_value,
          "datetime" => datetime,
          "battery_id" => battery_id,
          "il_value" => il_value,
          "mppt_value" => mppt_value,
          "load_value" => load_value,
          "p_value" => p_value,
          "consumed_amphours" => consumed_amphours,
          "soc_value" => soc_value,
          "time_to_go" => time_to_go,
          "alarm" => alarm,
          "relay" => relay,
          "ar_value" => ar_value,
          "bmv_value" => bmv_value
        }

        last_voltage = get_last_reading(battery_id) |> ensure_last_record
        save_battery_readings(voltage, last_voltage, params, battery_params)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.info "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error reason
    end
    :timer.sleep(10000)
  end

  defp ensure_last_record(nil), do: 0
  defp ensure_last_record(last_record), do: last_record.voltage

  defp save_battery_readings("0", _last_voltage, _params, _battery_params), do: Logger.error "Battery voltage is zero did not save."
  defp save_battery_readings(_, last_voltage, params, battery_params) do
    valid_datetime = params["datetime"] |> String.length
    ensure_datetime(valid_datetime, last_voltage, params, battery_params)
  end

  defp ensure_datetime(19, last_voltage, params, battery_params) do
    changeset = Reading.changeset(%Reading{}, params)
    case Repo.insert(changeset) do
    {:ok, _data} ->
      Logger.info "Battery status has been saved."
      voltage = params["voltage"] |> Decimal.new |> Decimal.to_integer
      ensure_voltage_value(last_voltage, voltage, battery_params)
    {:error, _changeset} ->
      Logger.error "Battery status did not save."
    end
  end
  defp ensure_datetime(_datetime_length, _last_voltage, _params, _battery_params), do: Logger.error "Battery datetime is wrong did not save."

  def get_battery_record(conn, params)  do
    battery_id = params["id"]
    from_date = params["fromDate"]
    to_date = params["toDate"]

    [column, order] = params["sort"] |> String.split("|")
    query = "select * from battery_reading as bt Where (DATE(datetime) >= '#{from_date}' and DATE(datetime) <= '#{to_date}') and (bt.battery_id = #{battery_id}) #{add_sorting(column, order)}"
    data = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map data.columns, &(String.to_atom(&1))
    roles = Enum.map data.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = data.num_rows
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      case total_records <= 0 do
        true -> []
        _ ->
          Enum.reduce(display_start..index_end, [], fn i, acc ->
            data = Enum.at(roles, i)
            lg = %{
              id: data[:id],
              voltage: data[:voltage],
              datetime: data[:datetime],
              serial_no: data[:serial_no],
              i_value: data[:i_value],
              vpv_value: data[:vpv_value],
              ppv_value: data[:ppv_value],
              cs_value: data[:cs_value],
              err_value: data[:err_value],
              h19_value: data[:h19_value],
              h20_value: data[:h20_value],
              h21_value: data[:h21_value],
              h22_value: data[:h22_value],
              h23_value: data[:h23_value],
              il_value: data[:il_value],
              mppt_value: data[:mppt_value],
              load_value: data[:load_value],
              p_value: data[:p_value],
              consumed_amphours: data[:consumed_amphours],
              soc_value: data[:soc_value],
              time_to_go: data[:time_to_go],
              alarm: data[:alarm],
              relay: data[:relay],
              ar_value: data[:ar_value],
              bmv_value: data[:bmv_value],
              h1_value: data[:h1_value],
              h2_value: data[:h2_value],
              h3_value: data[:h3_value],
              h4_value: data[:h4_value],
              h5_value: data[:h5_value],
              h6_value: data[:h6_value],
              h7_value: data[:h7_value],
              h8_value: data[:h8_value],
              h9_value: data[:h9_value],
              h10_value: data[:h10_value],
              h11_value: data[:h11_value]
            }
            acc ++ [lg]
          end)
      end

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/battery/data?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/battery/data?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  def get_all_readings_by_battery(conn, params) do
    battery_id = params["id"]
    from_date = params["from"]
    to_date = params["to"]

    batteries =
    get_readings(from_date, to_date, battery_id)
      |> Enum.map(fn(battery) ->
        %{
          "pid" => battery.pid,
          "fw" => battery.fw,
          "serial_no" => battery.serial_no,
          "voltage" => battery.voltage,
          "i_value" => battery.i_value,
          "vpv_value" => battery.vpv_value,
          "ppv_value" => battery.ppv_value,
          "cs_value" => battery.cs_value,
          "err_value" => battery.err_value,
          "h1_value" => battery.h1_value,
          "h2_value" => battery.h2_value,
          "h3_value" => battery.h3_value,
          "h4_value" => battery.h4_value,
          "h5_value" => battery.h5_value,
          "h6_value" => battery.h6_value,
          "h7_value" => battery.h7_value,
          "h8_value" => battery.h8_value,
          "h9_value" => battery.h9_value,
          "h10_value" => battery.h10_value,
          "h11_value" => battery.h11_value,
          "h19_value" => battery.h19_value,
          "h20_value" => battery.h20_value,
          "h21_value" => battery.h21_value,
          "h22_value" => battery.h22_value,
          "h23_value" => battery.h23_value,
          "datetime" => battery.datetime,
          "battery_id" => battery.battery_id,
          "il_value" => battery.il_value,
          "mppt_value" => battery.mppt_value,
          "load_value" => battery.load_value,
          "p_value" => battery.p_value,
          "consumed_amphours" => battery.consumed_amphours,
          "soc_value" => battery.soc_value,
          "time_to_go" => battery.time_to_go,
          "alarm" => battery.alarm,
          "relay" => battery.relay,
          "ar_value" => battery.ar_value,
          "bmv_value" => battery.bmv_value
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        batteries: batteries
      })
  end

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("voltage", order), do: "ORDER BY voltage #{order}"
  defp add_sorting("datetime", order), do: "ORDER BY datetime #{order}"
  defp add_sorting("serial_no", order), do: "ORDER BY serial_no #{order}"
  defp add_sorting("i_value", order), do: "ORDER BY i_value #{order}"
  defp add_sorting("vpv_value", order), do: "ORDER BY vpv_value #{order}"
  defp add_sorting("ppv_value", order), do: "ORDER BY ppv_value #{order}"
  defp add_sorting("cs_value", order), do: "ORDER BY cs_value #{order}"

  defp ensure_voltage_value(last_voltage, voltage, battery_params) when last_voltage != voltage  do
    name = battery_params[:name]
    url = battery_params[:url]
    value_in_volt = voltage / 1000
    voltage_rules = EdgeCommander.Commands.get_battery_voltages_rule_list()
    Enum.each(voltage_rules, fn(rule) ->
      variable = rule.variable
      value = rule.value
      params = %{
        total_sms: value_in_volt,
        variable: variable,
        value: value,
        alert_for: "battery_voltage_alert",
        name: name,
        url: url
      }

      Util.condition_for_sms_alert(params)
     end)
  end
  defp ensure_voltage_value(_last_voltage, _voltage, _battery_params), do: :noop;

  defp element_value_and_remainng_data(list_data, column) do
    value =
      list_data
      |> Enum.map(fn(element) ->
        existence = element =~ column
        check_element_existence(existence, element)
      end)
      |> Enum.sort(&(&2 > &1))
      |> Enum.drop_while(fn(x) -> x == "" end)

    string_value = List.first(value) |> is_list_empty(column)
    last_chrector = String.last(string_value)
    convert_voltage_units(last_chrector, string_value, list_data, column)
  end

  defp convert_voltage_units("V", string_value, list_data, _column) do
    value_in_volts = string_value |> String.slice(0..-2) |> String.to_float()
    column_value = Kernel.round(value_in_volts * 1000) |> Util.convert_into_string
    remain_data = list_data |> Enum.reject(fn(x) -> x == column_value end)
    %{
      value: column_value,
      remain_data: remain_data
    }
  end
  defp convert_voltage_units(_, column_value, list_data, column) do
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