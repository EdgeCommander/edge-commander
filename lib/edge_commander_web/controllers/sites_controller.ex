defmodule EdgeCommanderWeb.SitesController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Sites.Records
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Sites, only: [get_records!: 1, get_sites_by_user: 1]
  import EdgeCommander.Devices, only: [get_router!: 1, get_nvr!: 1]
  import EdgeCommander.Accounts, only: [current_user: 1, get_current_resource: 1]
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Site: swagger_schema do
        title "Site"
        description "A site module of the application"
        properties do
          id :integer, ""
          sim_number :string, "", required: true
          router_name :string, "", required: true
          router_id :integer, "", required: true
          nvr_name :string, "", required: true
          nvr_id :integer, "", required: true
          notes :string, ""
          name :string, "", required: true
          location (Schema.new do
            properties do
              lat :float, ""
              lng :float, ""
              map_area :string, ""
            end
          end)
          created_at :string, "", required: true
        end
      end
    }
  end

  swagger_path :get_all_sites_by_users do
    get "/v1/sites"
    description "Returns sites list"
    summary "Returns all sites"
    parameters do
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sites"
    response 200, "Success"
  end

  swagger_path :delete_site do
    delete "/v1/sites/{id}"
    summary "Delete site by ID"
    parameters do
      id :path, :string, "Site id to delete", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sites"
    response 200, "Success"
  end

  def create(conn, params) do
    changeset = Records.changeset(%Records{}, params)
    case Repo.insert(changeset) do
      {:ok, site} ->
        %EdgeCommander.Sites.Records{
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

        name = params["name"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Site: <span>#{name}</span> was created",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

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

  def get_all_sites_by_users(conn, params) do
    user_id = Util.get_user_id(conn, params)
    sites =
      get_sites_by_user(user_id)
      |> Enum.map(fn(site) ->
        %{
          "id" => site.id,
          "name" => site.name,
          "sim_number" => site.sim_number,
          "router_name" => site.router_id |> get_router_name,
          "router_id" => site.router_id,
          "nvr_name" => site.nvr_id |> get_nvr_name,
          "nvr_id" => site.nvr_id,
          "notes" => site.notes,
          "location" => site.location,
          "created_at" => site.inserted_at
        }
      end)

    conn
    |> put_status(200)
    |> json(%{
        sites: sites
      })
  end

  def get_all_sites(conn, params)  do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = "select * from sites as s Where lower(s.name) like lower('%#{search}%') #{add_sorting(column, order)}"
    sites = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map sites.columns, &(String.to_atom(&1))
    roles = Enum.map sites.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = sites.num_rows
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
              site = Enum.at(roles, i)
              st = %{
              id: site[:id],
              name: site[:name],
              sim_number: site[:sim_number],
              router_name: site[:router_id] |> get_router_name,
              router_id: site[:router_id],
              nvr_name: site[:nvr_id] |> get_nvr_name,
              nvr_id: site[:nvr_id],
              notes: site[:notes],
              lng: site[:location] |> Map.get("lng"),
              lat: site[:location] |> Map.get("lat"),
              map_area: site[:location] |> Map.get("map_area"),
              created_at: site[:inserted_at] |> Util.shift_zone()
            }
            acc ++ [st]
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
        next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/sites/data?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
        prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/sites/data?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
      }
      json(conn, records)
  end

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("name", order), do: "ORDER BY name #{order}"
  defp add_sorting("location", order), do: "ORDER BY location #{order}"
  defp add_sorting("sim_number", order), do: "ORDER BY sim_number #{order}"
  defp add_sorting("router_name", order), do: "ORDER BY router_id #{order}"
  defp add_sorting("nvr_name", order), do: "ORDER BY nvr_id #{order}"
  defp add_sorting("notes", order), do: "ORDER BY notes #{order}"
  defp add_sorting("created_at", order), do: "ORDER BY inserted_at #{order}"

  def update(conn, %{"id" => id} = params) do
    get_records!(id)
    |> Records.changeset(params)
    |> Repo.update
    |> case do
      {:ok, site} ->
        %EdgeCommander.Sites.Records{
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

        name = params["name"]
        current_user = current_user(conn)
        logs_params = %{
        "event" => "Site: <span>#{name}</span> was updated",
        "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

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

  def delete_site(conn, %{"id" => id} = _params) do
    current_user = get_current_resource(conn)
    records = get_records!(id)
    records
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Sites.Records{}} ->
        conn
        |> put_status(200)
        |> json(%{
          deleted: true
        })
        name = records.name
        logs_params = %{
          "event" => "Site: <span>#{name}</span> was deleted",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)
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