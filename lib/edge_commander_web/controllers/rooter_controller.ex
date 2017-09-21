defmodule EdgeCommanderWeb.RooterController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  import EdgeCommander.Accounts, only: [current_user: 1]
  import Gravatar

  def index(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "index.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
    else
      _ ->
        conn
        |> put_flash(:error, "You must be logged in to see that page :).")
        |> redirect(to: "/users/sign_in")
    end
  end

  def sim_logs(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "sim_logs.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), csrf_token: get_csrf_token())
    else
      _ ->
        conn
        |> put_flash(:error, "You must be logged in to see that page :).")
        |> redirect(to: "/users/sign_in")
    end
  end

  def status_report(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "status_report.html")
    else
      _ ->
        conn
        |> put_flash(:error, "You must be logged in to see that page :).")
        |> redirect(to: "/users/sign_in")
    end
  end
end
