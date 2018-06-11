defmodule EdgeCommanderWeb.DashboardController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  import EdgeCommander.Accounts, only: [current_user: 1]

  def sign_up(conn, _params) do
  with %User{} <- current_user(conn) do
    conn
    |> redirect(to: "/sims")
    else
      _ ->
        render(conn, "sign_up.html", csrf_token: get_csrf_token())
    end
  end

  def sign_in(conn, _params) do
    with %User{} <- current_user(conn) do
      conn
      |> redirect(to: "/sims")
    else
      _ ->
        render(conn, "sign_in.html", csrf_token: get_csrf_token())
    end
  end

  def forgot_password(conn, _params) do
    with %User{} <- current_user(conn) do
    conn
    |> redirect(to: "/sims")
    else
      _ ->
        render(conn, "forgot_password.html", csrf_token: get_csrf_token())
    end
  end

  def reset_password(conn, %{"token" => token} = _params) do
    with %User{} <- current_user(conn) do
    conn
    |> redirect(to: "/sims")
    else
      _ ->
        render(conn, "reset_password.html", csrf_token: get_csrf_token(), token: token)
    end
  end
end
