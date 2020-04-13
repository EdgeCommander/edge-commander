defmodule EdgeCommanderWeb.NvrsController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Devices.Nvr
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Accounts, only: [current_user: 1, get_current_resource: 1]
  import EdgeCommander.Monitors
  import EdgeCommander.Devices, only: [update_nvr_ISAPI: 1, list_nvrs: 0, get_nvr!: 1, get_nvrs_by_user: 1]
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Nvr: swagger_schema do
        title "Nvr"
        description "A network video recorder of the application"
        properties do
          created_at :string, ""
          extra (Schema.new do
            properties do
              device_id :string, ""
              device_name :string, ""
              device_type :string, ""
              encoder_released_date :string, ""
              encoder_version :string, ""
              firmware_released_date :string, ""
              mac_address :string, ""
              reason :string, ""
              serial_number :string, ""
            end
          end)
          firmware_version :string, ""
          id :integer, ""
          ip :integer, "", required: true
          is_monitoring :boolean, "", default: false, required: true
          model :string, ""
          name :string, "", required: true
          nvr_status :boolean, ""
          username :string, "", required: true
          password :string, "", required: true
          port :integer, "", required: true
          vh_port :integer, "", required: true
          rtsp_port :integer, "", required: true
          sdk_port :integer, "", required: true
        end
      end
    }
  end

  swagger_path :get_all_nvrs_by_users do
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

  swagger_path :delete_nvr do
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

  swagger_path :get_single_nvr do
    get "/v1/nvrs/{id}"
    summary "Returns nvr details by ID"
    parameters do
      id :path, :string, "ID of nvr that needs to be fetch", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "nvrs"
    response 201, "Success"
  end

  def create(conn, params) do
    current_user = get_current_resource(conn)
    params = Map.merge(params, %{"user_id" => current_user.id})
    changeset = Nvr.changeset(%Nvr{}, params)
    case Repo.insert(changeset) do
      {:ok, nvr} ->
        %EdgeCommander.Devices.Nvr{
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

  def get_all_nvrs_by_users(conn, params) do
    user_id = Util.get_user_id(conn, params)
    nvrs =
      get_nvrs_by_user(user_id)
      |> Enum.map(fn(nvr) ->
        %{
          "id" => nvr.id,
          "name" => nvr.name,
          "username" => nvr.username,
          "password" => nvr.password,
          "ip" => nvr.ip,
          "port" => nvr.port,
          "is_monitoring" => nvr.is_monitoring,
          "created_at" => nvr.inserted_at,
          "firmware_version" => nvr.firmware_version,
          "model" => nvr.model,
          "extra" => nvr.extra,
          "vh_port" => nvr.vh_port,
          "sdk_port" => nvr.sdk_port,
          "rtsp_port" => nvr.rtsp_port,
          "nvr_status" => nvr.nvr_status
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        nvrs: nvrs
      })
  end

  def get_all_nvrs(conn, params)  do

    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = "select * from nvrs as n Where lower(n.name) like lower('%#{search}%') or lower(n.ip) like lower('%#{search}%')  or lower(n.model) like lower('%#{search}%')  #{add_sorting(column, order)}"
    nvrs = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map nvrs.columns, &(String.to_atom(&1))
    roles = Enum.map nvrs.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = nvrs.num_rows
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
              nvr = Enum.at(roles, i)
              nv = %{
              id: nvr[:id],
              name: nvr[:name],
              username: nvr[:username],
              password: nvr[:password],
              ip: nvr[:ip],
              port: nvr[:port],
              is_monitoring: nvr[:is_monitoring],
              created_at: nvr[:inserted_at] |> Util.shift_zone(),
              firmware_version: nvr[:firmware_version],
              model: nvr[:model],
              extra: nvr[:extra],
              vh_port: nvr[:vh_port],
              sdk_port: nvr[:sdk_port],
              rtsp_port: nvr[:rtsp_port],
              nvr_status: nvr[:nvr_status]
            }
            acc ++ [nv]
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
        next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/nvrs/data?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
        prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/nvrs/data?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
      }
      json(conn, records)
  end

  def get_all(conn, _params)  do
    nvrs =
      list_nvrs()
      |> Enum.map(fn(nvr) ->
        %{
          "id" => nvr.id,
          "name" => nvr.name
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
      nvrs: nvrs
    })
  end
  
  def delete_nvr(conn, %{"id" => id} = _params) do
    current_user = get_current_resource(conn)
    records = get_nvr!(id)
    records
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Devices.Nvr{}} ->
        conn
        |> put_status(200)
        |> json(%{
          deleted: true
        })
        name = records.name
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

  def get_single_nvr(conn, %{"id" => id} = _params) do
    data = get_nvr!(id)
    conn
    |> put_status(:ok)
    |> json(%{
      "name" => data.name,
      "username" => data.username,
      "password" => data.password,
      "ip" => data.ip,
      "port" => data.port,
      "vh_port" => data.vh_port,
      "rtsp_port" => data.rtsp_port,
      "sdk_port" => data.sdk_port,
      "is_monitoring" => data.is_monitoring,
      "created_at" => data.inserted_at
    })
  end

  def update(conn, %{"id" => id} = params) do
    get_nvr!(id)
    |> Nvr.changeset(params)
    |> Repo.update
    |> case do
      {:ok, nvr} ->
        %EdgeCommander.Devices.Nvr{
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
        current_user = get_current_resource(conn)
        logs_params = %{
        "event" => "NVR: <span>#{name}</span> was updated",
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
      api_id: System.get_env("SERVER_API_ID"),
      api_key: System.get_env("SERVER_API_KEY"),
      ip: ip,
      port: sdk_port,
      user: username,
      password: password
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
    all_logs = get_logs_for_days(days, current_user.id)

    current_user_nvrs = Nvr |> Repo.all
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
      data: formated_data
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

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("name", order), do: "ORDER BY name #{order}"
  defp add_sorting("username", order), do: "ORDER BY username #{order}"
  defp add_sorting("password", order), do: "ORDER BY password #{order}"
  defp add_sorting("ip", order), do: "ORDER BY ip #{order}"
  defp add_sorting("port", order), do: "ORDER BY port #{order}"
  defp add_sorting("is_monitoring", order), do: "ORDER BY is_monitoring #{order}"
  defp add_sorting("created_at", order), do: "ORDER BY created_at #{order}"
  defp add_sorting("firmware_version", order), do: "ORDER BY firmware_version #{order}"
  defp add_sorting("model", order), do: "ORDER BY model #{order}"
  defp add_sorting("extra", order), do: "ORDER BY extra #{order}"
  defp add_sorting("vh_port", order), do: "ORDER BY vh_port #{order}"
  defp add_sorting("sdk_port", order), do: "ORDER BY sdk_port #{order}"
  defp add_sorting("rtsp_port", order), do: "ORDER BY rtsp_port #{order}"
  defp add_sorting("nvr_status", order), do: "ORDER BY nvr_status #{order}"

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
