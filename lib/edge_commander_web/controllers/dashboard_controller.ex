defmodule EdgeCommanderWeb.DashboardController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  alias EdgeCommander.Accounts.Guardian
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
    |> sign_out(token)
    else
      _ ->
        render(conn, "reset_password.html", csrf_token: get_csrf_token(), token: token)
    end
  end

  def reset_password_success(conn, _params) do
    render(conn, "reset_password_success.html", csrf_token: get_csrf_token())
  end

  def sign_out(conn, token) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: "/users/reset_password/#{token}")
  end

end
