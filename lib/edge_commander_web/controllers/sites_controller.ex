defmodule EdgeCommanderWeb.SitesController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Sites.Records
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Sites, only: [list_sites: 0, get_records!: 1]
  import EdgeCommander.Devices, only: [get_router!: 1, get_nvr!: 1]

  def create(conn, params) do
    changeset = Records.changeset(%Records{}, params)
    case Repo.insert(changeset) do
      {:ok, site} ->
        %EdgeCommander.Sites.Records{
          name: name,
          location: %{
            "lat" => latitude,
            "lng" => longitude,
            "map_area" => map_area
          },
          sim_number: sim_number,
          router_id: router_id,
          nvr_id: nvr_id,
          notes: notes,
          user_id: user_id
        } = site

        conn
        |> put_status(:created)
        |> json(%{
          "name" => name,
          "lat" => latitude,
          "lng" => longitude,
          "map_area" => map_area,
          "sim_number" => sim_number,
          "router_id" => router_id,
          "nvr_id" => nvr_id,
          "notes" => notes,
          "user_id" => user_id
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{errors: traversed_errors})
    end
  end

  def get_all_sites(conn, _params)  do
    sites = 
      list_sites()
      |> Enum.map(fn(site) ->
        %{
          id: site.id,
          name: site.name,
          location: site.location,
          sim_number: site.sim_number,
          router_name: site.router_id |> get_router_name,
          router_id: site.router_id,
          nvr_name: site.nvr_id |> get_nvr_name,
          nvr_id: site.nvr_id,
          notes: site.notes,
          created_at: site.inserted_at
        }
      end)
    conn
    |> put_status(200)
    |> json(sites)
  end

  def update(conn, %{"id" => id} = params) do
    get_records!(id)
    |> Records.changeset(params)
    |> Repo.update
    |> case do
      {:ok, site} ->
        %EdgeCommander.Sites.Records{
          name: name,
          location: %{
            "lat" => latitude,
            "lng" => longitude,
            "map_area" => map_area
          },
          sim_number: sim_number,
          router_id: router_id,
          nvr_id: nvr_id,
          notes: notes,
          inserted_at: inserted_at
        } = site

        conn
        |> put_status(:created)
        |> json(%{
          "name" => name,
          "lat" => latitude,
          "lng" => longitude,
          "map_area" => map_area,
          "sim_number" => sim_number,
          "router_id" => router_id,
          "nvr_id" => nvr_id,
          "notes" => notes,
          "created_at" => inserted_at
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{errors: traversed_errors})   
    end
  end

  def delete(conn, %{"id" => id} = _params) do
    get_records!(id)
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Sites.Records{}} ->
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
        |> json(%{errors: traversed_errors})
    end
  end

  defp get_router_name(id),  do: get_router!(id) |> Map.get(:name)

  defp get_nvr_name(id),  do: get_nvr!(id) |> Map.get(:name)
end