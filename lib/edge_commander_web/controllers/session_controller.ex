defmodule EdgeCommanderWeb.SessionController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Repo
  import EdgeCommander.Accounts, only: [login: 2, update_last_login: 2]

  def create(conn, params) do
    case login(params, Repo) do
      {:ok, user} ->
        update_last_login(params, Repo)
        conn
        |> put_session(:current_user, user.id)
        |> put_flash(:info, "You have logged in.")
        |> redirect(to: "/")
      :error ->
        conn
        |> put_flash(:error, "Wrong email or password.")
        |> redirect(to: "/users/sign_in")
    end
  end

  def delete(conn, _) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/users/sign_in")
  end
end
