defmodule EdgeCommanderWeb.RoutersController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Devices.Router
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Devices, only: [list_routers: 0, get_router!: 1]
  import EdgeCommander.Accounts, only: [current_user: 1]
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Router: swagger_schema do
        title "Router"
        description "A router of the application"
        properties do
          id :integer, ""
          name :string, ""
          username :string, ""
          password :string, ""
          ip :integer, ""
          port :integer, ""
          is_monitoring :boolean, "", default: false
        end
      end
    }
  end

  swagger_path :get_all_routers do
    get "/v1/routers"
    description "Returns routers list"
    summary "Returns all routers"
    parameters do
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "routers"
    response 200, "Success"
  end

  swagger_path :create do
    post "/v1/routers"
    summary "Add a new router"
    parameters do
      name :query, :string, "", required: true
      username :query, :string, "", required: true
      password :query, :string, "", required: true
      ip :query, :string, "", required: true
      port :query, :integer, "", required: true
      is_monitoring :query, :boolean, "", default: false
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "routers"
    response 201, "Success"
  end

  swagger_path :update do
    patch "/v1/routers/{id}"
    summary "Updates a router by ID"
    parameters do
      id :path, :string, "ID of router that needs to be updated", required: true
      name :query, :string, "Updated name of the router"
      username :query, :string, "Updated username of the router"
      password :query, :string, "Updated password of the router"
      ip :query, :string, "Updated ip of the router"
      port :query, :integer, "Updated port of the router"
      is_monitoring :query, :boolean, ""
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "routers"
    response 201, "Success"
  end

  swagger_path :delete_router do
    delete "/v1/routers/{id}"
    summary "Delete router by ID"
    parameters do
      id :path, :string, "Router id to delete", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "routers"
    response 201, "Success"
  end

  def create(conn, params) do
    changeset = Router.changeset(%Router{}, params)
    case Repo.insert(changeset) do
      {:ok, router} ->
        %EdgeCommander.Devices.Router{
          username: username,
          password: password,
          ip: ip,
          port: port,
          is_monitoring: is_monitoring,
          inserted_at: inserted_at
        } = router

        name = params["name"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Router: <span>#{name}</span> was created.",
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
          "port" => port,
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

  def get_all_routers(conn, params)  do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = "select * from routers as r Where lower(r.name) like lower('%#{search}%') or lower(r.ip) like lower('%#{search}%') #{add_sorting(column, order)}"
    routers = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map routers.columns, &(String.to_atom(&1))
    roles = Enum.map routers.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = routers.num_rows
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
              router = Enum.at(roles, i)
              ru = %{
              id: router[:id],
              name: router[:name],
              username: router[:username],
              password: router[:password],
              ip: router[:ip],
              port: router[:port],
              is_monitoring: router[:is_monitoring],
              created_at: router[:inserted_at] |> Util.shift_zone(),
              extra: router[:extra]
            }
            acc ++ [ru]
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
        next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/sims/data/json?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
        prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/sims/data/json?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
      }
      json(conn, records)
  end

  def update(conn, %{"id" => id} = params) do
    get_router!(id)
    |> Router.changeset(params)
    |> Repo.update
    |> case do
      {:ok, router} ->
        %EdgeCommander.Devices.Router{
          username: username,
          password: password,
          ip: ip,
          port: port,
          is_monitoring: is_monitoring,
          inserted_at: inserted_at
        } = router

        name = params["name"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Router: <span>#{name}</span> was updated.",
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
          "port" => port,
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

  def delete_router(conn, %{"id" => id} = _params) do
    records = get_router!(id)
    records
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Devices.Router{}} ->
        conn
        |> put_status(200)
        |> json(%{
          deleted: true
        })
        name = records.name
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Router: <span>#{name}</span> was deleted.",
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

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("name", order), do: "ORDER BY name #{order}"
  defp add_sorting("username", order), do: "ORDER BY username #{order}"
  defp add_sorting("password", order), do: "ORDER BY password #{order}"
  defp add_sorting("ip", order), do: "ORDER BY ip #{order}"
  defp add_sorting("port", order), do: "ORDER BY port #{order}"
  defp add_sorting("is_monitoring", order), do: "ORDER BY is_monitoring #{order}"
  defp add_sorting("created_at", order), do: "ORDER BY created_at #{order}"
end
