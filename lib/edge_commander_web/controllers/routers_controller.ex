defmodule EdgeCommanderWeb.RoutersController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Devices.Router
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Devices, only: [list_routers: 0, get_router!: 1]

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
