defmodule EdgeCommanderWeb.NvrsController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Devices.Nvr
  alias EdgeCommander.Sharing.Member
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Accounts, only: [current_user: 1]
  import EdgeCommander.Monitors
  import EdgeCommander.Devices, only: [update_nvr_ISAPI: 1, list_nvrs: 1, get_nvr!: 1]
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Nvr: swagger_schema do
        title "Nvr"
        description "A network video recorder of the application"
        properties do
          id :integer, ""
          name :string, "", required: true
          username :string, "", required: true
          password :string, "", required: true
          ip :integer, "", required: true
          port :integer, "", required: true
          vh_port :integer, "", required: true
          rtsp_port :integer, "", required: true
          sdk_port :integer, "", required: true
          is_monitoring :boolean, "", default: false, required: true
          nvr_status :boolean, ""
          model :string, ""
          mac_address :string, ""
          firmware_version :string, ""
          firmware_released_date :string, ""
          encoder_version :string, ""
          encoder_released_date :string, ""
          serial_number :string, ""
          reason :string, "Offline reason"
        end
      end
    }
  end

  swagger_path :get_all_nvrs do
    get "/v1/nvrs"
    description "Returns nvrs list"
    summary "Returns all nvrs"
    parameters do
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "nvrs"
    response 200, "Success"
  end

  swagger_path :create do
    post "/v1/nvrs"
    summary "Add a new nvr"
    parameters do
      name :query, :string, "", required: true
      username :query, :string, "", required: true
      password :query, :string, "", required: true
      ip :query, :string, "", required: true
      port :query, :integer, "", required: true
      vh_port :query, :integer, "", required: true
      rtsp_port :query, :integer, "", required: true
      sdk_port :query, :integer, "", required: true
      is_monitoring :query, :boolean, "", default: false
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "nvrs"
    response 201, "Success"
  end

  swagger_path :delete do
    delete "/v1/nvrs/{id}"
    summary "Delete nvr by ID"
    parameters do
      id :path, :string, "Nvr id to delete", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "nvrs"
    response 200, "Success"
  end

  swagger_path :update do
    patch "/v1/nvrs/{id}"
    summary "Update nvr by ID"
    parameters do
      id :path, :string, "ID of nvr that needs to be updated", required: true
      name :query, :string, "Updated name of the nvr"
      username :query, :string, "Updated username of the nvr"
      password :query, :string, "Updated password of the nvr"
      ip :query, :string, "Updated ip of the nvr"
      port :query, :integer, "Updated http port of the nvr"
      vh_port :query, :integer, "Updated vh port of the nvr"
      rtsp_port :query, :integer, "Updated rtsp port of the nvr"
      sdk_port :query, :integer, "Updated sdk port of the nvr"
      is_monitoring :query, :boolean, ""
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "nvrs"
    response 201, "Success"
  end

  def create(conn, params) do
    changeset = Nvr.changeset(%Nvr{}, params)
    case Repo.insert(changeset) do
      {:ok, nvr} ->
        %EdgeCommander.Devices.Nvr{
          name: name,
          username: username,
          password: password,
          ip: ip,
          port: http_port,
          vh_port: vh_port,
          rtsp_port: rtsp_port,
          sdk_port: sdk_port,
          is_monitoring: is_monitoring,
          inserted_at: inserted_at
        } = nvr

        update_nvr_ISAPI(nvr)

        name = params["name"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "NVR: A new <span>#{name}</span> was created",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        conn
        |> put_status(:created)
        |> json(%{
          "name" => name,
          "username" => username,
          "password" => password,
          "ip" => ip,
          "http_port" => http_port,
          "vh_port" => vh_port,
          "rtsp_port" => rtsp_port,
          "sdk_port" => sdk_port,
          "is_monitoring" => is_monitoring,
          "created_at" => inserted_at
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  def get_all_nvrs(conn, params)  do
    current_user = current_user(conn)
    current_user_id = Util.get_user_id(conn, params)
    nvrs = 
      list_nvrs(current_user_id)
      |> Enum.map(fn(nvr) ->
        %{
          id: nvr.id,
          name: nvr.name,
          username: nvr.username,
          password: nvr.password,
          ip: nvr.ip,
          port: nvr.port,
          is_monitoring: nvr.is_monitoring,
          created_at: nvr.inserted_at |> Util.shift_zone(),
          firmware_version: nvr.firmware_version,
          model: nvr.model,
          extra: nvr.extra,
          vh_port: nvr.vh_port,
          sdk_port: nvr.sdk_port,
          rtsp_port: nvr.rtsp_port,
          encoder_released_date: nvr |> get_extra_data("encoder_released_date"),
          encoder_version: nvr |> get_extra_data("encoder_version"),
          firmware_released_date: nvr |> get_extra_data("firmware_released_date"),
          serial_number: nvr |> get_extra_data("serial_number"),
          mac_address: nvr |> get_extra_data("mac_address"),
          reason: nvr |> get_extra_data("reason"),
          nvr_status: nvr.nvr_status
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        "nvrs": nvrs
      })
  end
  
  defp get_extra_data(nvr,extra_field) do
    nvr.extra
    |> get_extra_value(nvr, extra_field)
  end

  defp get_extra_value(nil, _, _), do: ""
  defp get_extra_value(_, nvr, extra_field),  do: nvr.extra |> Map.get(extra_field)

  def delete(conn, %{"id" => id} = _params) do
    records = get_nvr!(id)
    records
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Devices.Nvr{}} ->
        conn
        |> put_status(200)
        |> json(%{
          "deleted": true
        })
        name = records.name
        current_user = current_user(conn)
        logs_params = %{
          "event" => "NVR: <span>#{name}</span> was deleted",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  def update(conn, %{"id" => id} = params) do
    get_nvr!(id)
    |> Nvr.changeset(params)
    |> Repo.update
    |> case do
      {:ok, nvr} ->
        %EdgeCommander.Devices.Nvr{
          name: name,
          username: username,
          password: password,
          ip: ip,
          port: http_port,
          vh_port: vh_port,
          rtsp_port: rtsp_port,
          sdk_port: sdk_port,
          is_monitoring: is_monitoring,
          inserted_at: inserted_at
        } = nvr

        name = params["name"]
        current_user = current_user(conn)
        logs_params = %{
        "event" => "NVR: <span>#{name}</span>} was updated",
        "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        conn
        |> put_status(:created)
        |> json(%{
          "name" => name,
          "username" => username,
          "password" => password,
          "ip" => ip,
          "http_port" => http_port,
          "vh_port" => vh_port,
          "rtsp_port" => rtsp_port,
          "sdk_port" => sdk_port,
          "is_monitoring" => is_monitoring,
          "created_at" => inserted_at
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })   
    end
  end

  def reboot(conn, %{"id" => id} = _params) do
    records = get_nvr!(id)
    ip = records.ip
    sdk_port = records.sdk_port
    username = records.username
    password = records.password
    url = "https://#{System.get_env("SERVER_HOST")}/v1/sdk/nvr/reboot"
    body = Poison.encode!(%{
      "api_id": System.get_env("SERVER_API_ID"),
      "api_key": System.get_env("SERVER_API_KEY"),
      "ip": ip,
      "port": sdk_port,
      "user": username,
      "password": password
    })
    headers = [{"Content-type", "application/json"}]
    case HTTPoison.post(url, body, headers, []) do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code}} ->
       message =
          body
          |> Poison.decode
          |> elem(1)
          |> Map.get("message")

          name = records.name
          current_user = current_user(conn)
          logs_params = %{
            "event" => "NVR: <span>#{name}</span> was rebooted",
            "user_id" => current_user.id
          }
          Util.create_log(conn, logs_params)

        conn
        |> put_status(status_code)
        |> json(%{status: status_code, message: message})

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_status(400)
        |> json(%{message: reason})
    end
  end

  def update_status_report(conn, params) do
    days = get_history_days(params["history_days"])
    current_user = current_user(conn)
    current_user_id = current_user.id
    all_logs = get_logs_for_days(days, current_user.id)

    query = from n in Nvr,
      left_join: m in Member, on: n.user_id == m.user_id,
      where: (m.member_id == ^current_user_id or n.user_id == ^current_user_id)

    current_user_nvrs = query |> Repo.all
    nvr_logs =
      Enum.map(current_user_nvrs, fn (nvr) ->
        %{
          nvr_name: nvr.name,
          status: nvr.nvr_status,
          created_at: nvr.inserted_at |> Timex.to_datetime,
          logs: map_logs(all_logs, nvr.id)
        }
      end)

    formated_data =
      nvr_logs
      |> Enum.map(fn (log) ->
        %{
          measure_html: create_measure(log.nvr_name, log.status),
          data: fromat_logs(log.status, log.logs, "Etc/UTC", log.created_at, days)
        }
      end)

    conn
    |> put_status(200)
    |> json(%{
      "data": formated_data
    })
  end

  def fromat_logs(status, logs, _timezone, created_at, days) do
    {day, ""} = days |> Integer.parse
    days_in_seconds = day * 24 * 60 * 60
    starting_of_week =
      Calendar.DateTime.now_utc
      |> Timex.beginning_of_day()
      |> Calendar.DateTime.to_erl
      |> Calendar.DateTime.from_erl!("Etc/UTC", {123456, 6})
      |> Calendar.DateTime.advance!(days_in_seconds)

    no_event_logged =
      case DateTime.compare starting_of_week, created_at do
        :gt -> starting_of_week
        _ -> created_at
      end

    unshift_log =
      case length(logs) >= 1 do
        true ->
          [ %{done_at: no_event_logged, action: logs |> List.first |> set_action_single()} | logs]
        _ ->
          logs
      end

    cond do
      unshift_log == [] && status == false ->
        [[format_date_time(no_event_logged), 0, format_date_time(Calendar.DateTime.now_utc)]]
      unshift_log == [] && status == true ->
        [[format_date_time(no_event_logged), 1, format_date_time(Calendar.DateTime.now_utc)]]
      length(unshift_log) > 1 ->
        unshift_log
        |> Enum.with_index
        |> Enum.map(fn({log, index}) ->
          [format_date_time(log.done_at), digit_status(log.action), done_at_with_index(logs, index + 1, "Etc/UTC")]
        end)
    end
  end

  def done_at_with_index(logs, index, _timezone) do
    if index > length(logs) - 1 do
      Calendar.DateTime.now_utc
      |> Calendar.Strftime.strftime("%Y-%m-%d %H:%M:%S")
      |> elem(1)
    else
      Enum.at(logs, index) |> Map.get(:done_at) |> Calendar.Strftime.strftime("%Y-%m-%d %H:%M:%S") |> elem(1)
    end
  end

  def format_date_time(done_at) do
    done_at
    |> Calendar.Strftime.strftime("%Y-%m-%d %H:%M:%S")
    |> elem(1)
  end

  defp set_action_single(log) do
    case log.action do
      true -> false
      _ -> true
    end
  end

  def digit_status(action) do
    if action == true do
      1
    else
      0
    end
  end

  defp create_measure(nvr_name, status) do
    if status == true do
      nvr_name
    else
      "#{nvr_name}  <span class='fa fa-chain'></span>"
    end
  end

  def map_logs(all_logs, nvr_id) do
    if no_in_logs(all_logs, nvr_id) == nil do
      []
    else
      for log <- all_logs, log.nvr_id == nvr_id, do: %{done_at: log.done_at, action: log.status}
    end
  end

  defp no_in_logs(logs, nvr_id) do
    Enum.find(logs, fn(log) -> log.nvr_id == nvr_id end)
  end

  defp get_history_days(days) when days in [nil, ""], do: "-7"
  defp get_history_days(days) when is_integer(days), do: "-#{days}"
  defp get_history_days(days) when is_bitstring(days), do: get_history_days(to_integer(days))

  defp to_integer(value) do
    case Integer.parse(value) do
      {number, ""} -> number
      _ -> :error
    end
  end
end
