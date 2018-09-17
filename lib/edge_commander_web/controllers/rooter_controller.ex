defmodule EdgeCommanderWeb.RooterController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  import EdgeCommander.Accounts, only: [current_user: 1, get_other_users: 1]
  import EdgeCommander.Devices, only: [list_nvrs: 1, list_routers: 1]
  import EdgeCommander.Sharing, only: [all_shared_users: 1]
  import EdgeCommander.ThreeScraper, only: [all_sims: 1]
  import Gravatar
  require Logger

  def main(conn, _params) do
    render(conn, "main.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
  end

  def index(conn, _params) do
    render(conn, "index.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
  end
end