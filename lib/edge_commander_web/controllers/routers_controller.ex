defmodule EdgeCommanderWeb.RoutersController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Devices.Router
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Devices, only: [list_routers: 1, get_router!: 1]
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

  swagger_path :delete do
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
          name: name,
          username: username,
          password: password,
          ip: ip,
          port: port,
          is_monitoring: is_monitoring,
          inserted_at: inserted_at
        } = router

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
    current_user_id = Util.get_user_id(conn, params)
    routers = 
      list_routers(current_user_id)
      |> Enum.map(fn(router) ->
        %{
          id: router.id,
          name: router.name,
          username: router.username,
          password: router.password,
          ip: router.ip,
          port: router.port,
          is_monitoring: router.is_monitoring,
          created_at: router.inserted_at |> Util.shift_zone(),
          extra: router.extra
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        "routers": routers
      })
  end

  def update(conn, %{"id" => id} = params) do
    get_router!(id)
    |> Router.changeset(params)
    |> Repo.update
    |> case do
      {:ok, router} ->
        %EdgeCommander.Devices.Router{
          name: name,
          username: username,
          password: password,
          ip: ip,
          port: port,
          is_monitoring: is_monitoring,
          inserted_at: inserted_at
        } = router

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

  def delete(conn, %{"id" => id} = _params) do
    get_router!(id)
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Devices.Router{}} ->
        conn
        |> put_status(200)
        |> json(%{
          "deleted": true
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end
end
