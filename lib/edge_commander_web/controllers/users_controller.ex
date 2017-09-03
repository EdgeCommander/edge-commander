defmodule EdgeCommanderWeb.UsersController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Repo
  alias EdgeCommander.Accounts.User
  alias EdgeCommander.Util
  require Logger

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

  defp merge_last_signed_in(params) do
    {:ok, Map.merge(params, %{"last_signed_in" => Ecto.DateTime.utc})}
  end

  defp changeset_is_fine(params) do
    case changeset = User.changeset(%User{}, params) do
      %Ecto.Changeset{valid?: true} ->
        {:ok, changeset}
      %Ecto.Changeset{valid?: false} ->
        {:error, Util.parse_changeset(changeset)}
    end
  end
end
