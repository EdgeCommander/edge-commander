defmodule EdgeCommanderWeb.BatteryController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Solar.Battery
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Solar, only: [get_battery!: 1, get_last_reading: 1]
  import EdgeCommander.Accounts, only: [current_user: 1,  get_current_resource: 1]
  use PhoenixSwagger

  def create(conn, params) do
    changeset = Battery.changeset(%Battery{}, params)
    case Repo.insert(changeset) do
      {:ok, battery} ->
        %EdgeCommander.Solar.Battery{
          name: name,
          source_url: source_url,
          inserted_at: created_at,
          active: active
        } = battery

        battery_name = params["name"]
        current_user = get_current_resource(conn)
        logs_params = %{
          "event" => "Battery: <span>#{battery_name}</span> was created",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        conn
        |> put_status(:created)
        |> json(%{
          "name" => name,
          "source_url" => source_url,
          "created_at" => created_at,
          "active" => active
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  def get_all_batteries(conn, params)  do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = "select * from batteries as r Where lower(r.name) like lower('%#{search}%') or lower(r.source_url) like lower('%#{search}%') #{add_sorting(column, order)}"
    batteries = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map batteries.columns, &(String.to_atom(&1))
    roles = Enum.map batteries.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = batteries.num_rows
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
              battery = Enum.at(roles, i)
              last_reading_records = get_last_reading(battery[:id]) |> ensure_reading
              bt = %{
              id: battery[:id],
              name: battery[:name],
              source_url: battery[:source_url],
              active: battery[:active],
              last_seen: last_reading_records[:last_seen],
              last_voltage: last_reading_records[:last_voltage],
              created_at: battery[:inserted_at] |> Util.shift_zone()
            }
            acc ++ [bt]
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
        next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/battery?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
        prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/battery?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
      }
      json(conn, records)
  end

  def update(conn, %{"id" => id} = params) do
    get_battery!(id)
    |> Battery.changeset(params)
    |> Repo.update
    |> case do
      {:ok, _battery} ->
        battery_name = params["name"]
        current_user = current_user(conn)
        logs_params = %{
        "event" => "Battery: <span>#{battery_name}</span> was updated.",
        "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        conn
        |> put_status(:created)
        |> json(%{
          "name" => battery_name
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  def delete_battery(conn, %{"id" => id} = _params) do
    records = get_battery!(id)
    records
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Solar.Battery{}} ->
        conn
        |> put_status(200)
        |> json(%{
          deleted: true
        })
        battery_name = records.name
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Battery: <span>#{battery_name}</span> was deleted.",
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

  def get_single_battery(conn, %{"id" => battery_id} = _params) do
      data = get_battery!(battery_id)
      conn
      |> put_status(:created)
      |> json(%{
        "name" => data.name,
        "source_url" => data.source_url
      })
  end

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("name", order), do: "ORDER BY name #{order}"
  defp add_sorting("source_url", order), do: "ORDER BY source_url #{order}"
  defp add_sorting("active", order), do: "ORDER BY active #{order}"
  defp add_sorting("created_at", order), do: "ORDER BY created_at #{order}"

  defp ensure_reading(nil) do
    %{
      last_seen: nil,
      last_voltage: "0",
    }
  end
  defp ensure_reading(last_reading_records) do
    %{
      last_seen: last_reading_records.datetime,
      last_voltage: last_reading_records.voltage,
    }
  end

end
