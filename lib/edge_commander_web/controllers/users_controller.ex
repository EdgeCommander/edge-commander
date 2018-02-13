defmodule EdgeCommanderWeb.UsersController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Repo
  alias EdgeCommander.Accounts.User
  alias EdgeCommander.Util
  require Logger
  import EdgeCommander.Accounts, only: [get_user!: 1]

  def sign_up(conn, params) do
    with  {:ok, updated_params} <- merge_last_signed_in(params),
          {:ok, changeset} <- changeset_is_fine(updated_params)
    do
      case Repo.insert(changeset) do
        {:ok, user} ->
          Logger.info "[POST /create_user] [#{user.email}] [#{user.last_signed_in}]"
          conn
          |> put_flash(:info, "Your account has been created.")
          |> put_session(:current_user, user.id)
          |> redirect(to: "/")
        {:error, changeset} ->
          errors = Util.parse_changeset(changeset)
          traverse_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
          conn
          |> put_flash(:error, traverse_errors |> List.first)
          |> redirect(to: "/users/sign_up")
      end
    else
      {:error, errors} ->
        error = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_flash(:error, error |> List.first)
        |> redirect(to: "/users/sign_up")
    end
  end

  def update_profile(conn, %{"id" => id} = params) do
    get_user!(id)
    |> User.changeset(params)
    |> Repo.update
    |> case do
      {:ok, user} ->
        %User{
          firstname: firstname,
          lastname: lastname,
          email: email,
          password: password,
          id: id
        } = user

        conn
        |> put_status(:created)
        |> json(%{
          "firstname" => firstname,
          "lastname" => lastname,
          "email" => email,
          "password" => password,
          "id" => id
        })

      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
      end
  end

  defp merge_last_signed_in(params) do
    username = String.split(params["email"], "@") |> List.first
    {:ok, Map.merge(params, %{"username" => username, "last_signed_in" => Ecto.DateTime.utc})}
  end

  defp changeset_is_fine(params) do
    api_id = UUID.uuid4(:hex) |> String.slice(0..7)
    api_key = UUID.uuid4(:hex)
    updated_params = Map.merge(params, %{"api_key" => api_key, "api_id" => api_id})
    case changeset = User.changeset(%User{}, updated_params) do
      %Ecto.Changeset{valid?: true} ->
        {:ok, changeset}
      %Ecto.Changeset{valid?: false} ->
        {:error, Util.parse_changeset(changeset)}
    end
  end
end
