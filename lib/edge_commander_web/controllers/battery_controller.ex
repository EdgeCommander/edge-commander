defmodule EdgeCommanderWeb.BatteryController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Solar.Battery
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Solar, only: [list_batteries: 1, get_battery!: 1]
  import EdgeCommander.Accounts, only: [current_user: 1]
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
        current_user = current_user(conn)
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
    current_user_id = Util.get_user_id(conn, params)
    batteries =
      list_batteries(current_user_id)
      |> Enum.map(fn(battery) ->
        %{
          id: battery.id,
          name: battery.name,
          source_url: battery.source_url,
          active: battery.active,
          created_at: battery.inserted_at |> Util.shift_zone()
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        batteries: batteries
      })
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

  def get_single_battery(conn, %{"battery_id" => battery_id} = _params) do
      data = get_battery!(battery_id)
      conn
      |> put_status(:created)
      |> json(%{
        "name" => data.name,
        "source_url" => data.source_url
      })
  end
end
