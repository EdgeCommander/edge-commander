defmodule EdgeCommanderWeb.SessionController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Repo
  import Plug.Conn
  import EdgeCommander.Accounts, only: [login: 2, update_last_login: 2, authenticate_user: 2, current_user: 1]
  alias EdgeCommander.Accounts.User
  alias EdgeCommander.Accounts.Guardian
  alias EdgeCommander.Util

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
    conn
    |> put_flash(:info, "You have logged in.")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/sims")
  end
end
