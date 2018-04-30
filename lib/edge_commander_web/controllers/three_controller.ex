defmodule EdgeCommanderWeb.ThreeController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.ThreeScraper.ThreeUsers
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Accounts, only: [current_user: 1]

  def create(conn, params) do
    changeset = ThreeUsers.changeset(%ThreeUsers{}, params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        %EdgeCommander.ThreeScraper.ThreeUsers{
          username: username,
          password: password,
          user_id: user_id
        } = user

        conn
        |> put_status(:created)
        |> json(%{
          "username" => username,
          "password" => password,
          "user_id" => user_id
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
          created_at: user.inserted_at |> Util.shift_zone()
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        "users": users
      })
  end

  def update(conn, %{"id" => id} = params) do
    ThreeUsers.get_three_account!(id)
    |> ThreeUsers.changeset(params)
    |> Repo.update
    |> case do
      {:ok, user} ->
        %EdgeCommander.ThreeScraper.ThreeUsers{
          username: username,
          password: password,
          updated_at: updated_at
        } = user

        conn
        |> put_status(:created)
        |> json(%{
          "username" => username,
          "password" => password,
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
    ThreeUsers.get_three_accounts!(id)
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.ThreeScraper.ThreeUsers{}} ->
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
