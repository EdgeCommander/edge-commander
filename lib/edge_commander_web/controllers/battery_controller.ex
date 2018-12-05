defmodule EdgeCommanderWeb.BatteryController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Solar.Battery
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import EdgeCommander.Solar, only: [list_battery: 0]
  import Ecto.Query, warn: false
  require Logger

  def save_status_data() do
    url = "http://solarcam2-fullrec.ddns.net/battery.html"
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data = String.split(body, "\n")
        params = %{
          "pid" => get_column_value(data, 2, "PID"),
          "fw" => get_column_value(data, 4, "FW"),
          "serial_no" => get_column_value(data, 6, "SER#"),
          "voltage" => get_column_value(data, 8, "V"),
          "i_value" => get_column_value(data, 10, "I"),
          "vpv_value" => get_column_value(data, 12, "VPV"),
          "ppv_value" => get_column_value(data, 14, "PPV"),
          "cs_value" => get_column_value(data, 16, "CS"),
          "err_value" => get_column_value(data, 18, "ERR"),
          "h19_value" => get_column_value(data, 20, "H19"),
          "h20_value" => get_column_value(data, 22, "H20"),
          "h21_value" => get_column_value(data, 24, "H21"),
          "h22_value" => get_column_value(data, 26, "H22"),
          "h23_value" => get_column_value(data, 28, "H23"),
          "datetime" => Enum.at(data, 30)
        }
        changeset = Battery.changeset(%Battery{}, params)
        case Repo.insert(changeset) do
        {:ok, _data} ->
          Logger.info "Battery status has been saved."
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
    records =
      list_battery()
      |> Enum.map(fn(data) ->
        %{
          id: data.id,
          voltage: data.voltage,
          datetime: data.datetime,
          serial_no: data.serial_no
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
end
