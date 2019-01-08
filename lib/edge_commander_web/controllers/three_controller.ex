defmodule EdgeCommanderWeb.ThreeController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.ThreeScraper.ThreeUsers
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Accounts, only: [current_user: 1]
  import ThreeScraper.Scraper, only: [single_start_scraper: 1]

  def create(conn, params) do
    changeset = ThreeUsers.changeset(%ThreeUsers{}, params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        %EdgeCommander.ThreeScraper.ThreeUsers{
          password: password,
          user_id: user_id,
          bill_day: bill_day
        } = user

        username = params["username"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Three: username <span>#{username}</span> was created.",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        spawn fn -> single_start_scraper(user.id) end

        conn
        |> put_status(:created)
        |> json(%{
          "username" => username,
          "password" => password,
          "user_id" => user_id,
          "bill_day" => bill_day
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  def get_all_three_accounts(conn, _params)  do
    current_user = current_user(conn)
    current_user_id = current_user.id
    users = 
      ThreeUsers.list_three_accounts(current_user_id)
      |> Enum.map(fn(user) ->
        %{
          id: user.id,
          username: user.username,
          password: user.password,
          user_id: user.user_id,
          bill_day: user.bill_day,
          created_at: user.inserted_at |> Util.shift_zone()
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        users: users
      })
  end

  def update(conn, %{"id" => id} = params) do
    ThreeUsers.get_three_account!(id)
    |> ThreeUsers.changeset(params)
    |> Repo.update
    |> case do
      {:ok, user} ->
        %EdgeCommander.ThreeScraper.ThreeUsers{
          password: password,
          bill_day: bill_day,
          updated_at: updated_at
        } = user

        username = params["username"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Three: username <span>#{username}</span> was updated.",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        spawn fn -> single_start_scraper(user.id) end

        conn
        |> put_status(:created)
        |> json(%{
          "username" => username,
          "password" => password,
          "bill_day" => bill_day,
          "updated_at" => updated_at
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
    records = ThreeUsers.get_three_account!(id)
    records
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.ThreeScraper.ThreeUsers{}} ->
        conn
        |> put_status(200)
        |> json(%{
          deleted: true
        })
        username = records.username
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Three: username <span>#{username}</span> was deleted.",
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

end
