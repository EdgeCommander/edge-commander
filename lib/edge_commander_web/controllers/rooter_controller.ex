defmodule EdgeCommanderWeb.RooterController do
  use EdgeCommanderWeb, :controller
  import EdgeCommander.Accounts, only: [current_user: 1]
  import Gravatar

  def main(conn, _params) do
    render(conn, "main.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
  end

  def index(conn, _params) do
    render(conn, "index.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
  end
end