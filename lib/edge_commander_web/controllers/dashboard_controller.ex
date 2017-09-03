defmodule EdgeCommanderWeb.DashboardController do
  use EdgeCommanderWeb, :controller

  def sign_up(conn, _params) do
    # render conn, "sign_up.html"
    render(conn, "sign_up.html", csrf_token: get_csrf_token())
  end

  def sign_in(conn, _params) do
    render conn, "sign_in.html"
  end
end
