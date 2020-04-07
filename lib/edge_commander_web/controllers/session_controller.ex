defmodule EdgeCommanderWeb.SessionController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Repo
  import EdgeCommander.Accounts, only: [update_last_login: 2, authenticate_user: 2, current_user: 1]
  alias EdgeCommander.Accounts.Guardian
  alias EdgeCommander.Util

  def target_path(conn) do
    get_session(conn, :login_retargeting_path) |> ensure_path
  end

  defp ensure_path(nil), do: "/dashboard"
  defp ensure_path("/users/session"), do: "/dashboard"
  defp ensure_path(path), do: path

  def create(conn, params) do
    email = String.downcase(params["email"])
    password = params["password"]
    %{"user" => %{"email" => email, "password" => password}}
    authenticate_user(email, password)
    |> login_reply(conn)
  end

  def delete(conn, _) do
    current_user = current_user(conn)
    params = %{
      "event" => "Logout",
      "user_id" => current_user.id
    }
    Util.create_log(conn, params)
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: "/")
  end

  defp login_reply({:error, error}, conn) do
    conn
    |> put_flash(:error, error)
    |> redirect(to: "/")
  end

  defp login_reply({:ok, user}, conn) do
    params = %{
      "event" => "Login",
      "user_id" => user.id
    }
    Util.create_log(conn, params)
    update_last_login(%{"email" => user.email}, Repo)
    redirect_url = target_path(conn)
    conn
    |> put_flash(:info, "You have logged in.")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: redirect_url)
  end
end
