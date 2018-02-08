defmodule EdgeCommanderWeb.RoutersController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Devices.Router
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Devices, only: [list_routers: 0, get_router!: 1]
  use PhoenixSwagger

  swagger_path :get_all_routers do
    get "/v1/routers"
    description "Returns routers list"
    summary "Returns all routers"
    response 200, "Success"
  end

  swagger_path :create do
    post "/v1/routers"
    summary "Add a new router"
    parameters do
      name :query, :string, "Name", required: true
      username :query, :string, "Username", required: true
      password :query, :string, "Password", required: true
      ip :query, :string, "IP", required: true
      port :query, :integer, "Port", required: true
      is_monitoring :query, :boolean, "Is monitoring", default: false
    end
    response 201, "Success"
  end

  swagger_path :update do
    patch "/v1/routers/{router_id}"
    summary "Updates a router by ID"
    parameters do
      router_id :path, :string, "ID of router that needs to be updated", required: true
      name :query, :string, "Updated name of the router"
      username :query, :string, "Updated username of the router"
      password :query, :string, "Updated password of the router"
      ip :query, :string, "Updated IP of the router"
      port :query, :integer, "Updated port of the router"
      is_monitoring :query, :boolean, "Is monitoring"
    end
    response 201, "Success"
  end

  swagger_path :delete do
    delete "/v1/routers/{router_id}"
    description "Enter Router's ID"
    summary "Delete router by ID"
    parameters do
      router_id :path, :string, "Router ID", required: true
    end
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

  def get_all_routers(conn, _params)  do
    routers = 
      list_routers()
      |> Enum.map(fn(router) ->
        %{
          id: router.id,
          name: router.name,
          username: router.username,
          password: router.password,
          ip: router.ip,
          port: router.port,
          is_monitoring: router.is_monitoring,
          created_at: router.inserted_at,
          extra: router.extra
        }
      end)
    conn
    |> put_status(200)
    |> json(routers)
  end

  def update(conn, %{"router_id" => id} = params) do
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

  def delete(conn, %{"router_id" => id} = _params) do
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
