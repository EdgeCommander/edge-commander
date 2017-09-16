defmodule EdgeCommanderWeb.NvrsController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Devices.Nvr
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import EdgeCommander.Devices, only: [update_nvr_ISAPI: 1, list_nvrs: 0, get_nvr!: 1]
  require IEx

  def create(conn, params) do
    changeset = Nvr.changeset(%Nvr{}, params)
    case Repo.insert(changeset) do
      {:ok, nvr} ->
        %EdgeCommander.Devices.Nvr{
          name: name,
          username: username,
          password: password,
          ip: ip,
          port: port,
          is_monitoring: is_monitoring
        } = nvr

        update_nvr_ISAPI(nvr)

        conn
        |> put_status(:created)
        |> json(%{
          "name" => name,
          "username" => username,
          "password" => password,
          "ip" => ip,
          "port" => port,
          "is_monitoring" => is_monitoring
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  def get_all_nvrs(conn, _params)  do
    nvrs = 
      list_nvrs()
      |> Enum.map(fn(nvr) ->
        %{
          id: nvr.id,
          name: nvr.name,
          username: nvr.username,
          password: nvr.password,
          ip: nvr.ip,
          port: nvr.port,
          is_monitoring: nvr.is_monitoring,
          firmware_version: nvr.firmware_version,
          model: nvr.model,
          extra: nvr.extra
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
      "nvrs": nvrs
    })
  end

  def delete(conn, %{"id" => id} = _params) do
    get_nvr!(id)
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Devices.Nvr{}} ->
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
