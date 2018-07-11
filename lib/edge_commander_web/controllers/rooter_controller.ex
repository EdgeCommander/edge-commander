defmodule EdgeCommanderWeb.RooterController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  import EdgeCommander.Accounts, only: [current_user: 1, get_users: 1]
  import EdgeCommander.Devices, only: [list_nvrs: 1, list_routers: 1]
  import EdgeCommander.ThreeScraper, only: [all_sims: 1]
  import Gravatar
  require Logger

  def index(conn, _params) do
    render(conn, "index.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
  end

  def common(conn, _params) do
    render(conn, "common.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), csrf_token: get_csrf_token())
  end

  def sim_logs(conn, _params) do
    render(conn, "sim_logs.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), csrf_token: get_csrf_token())
  end

  def nvrs(conn, _params) do
    render(conn, "nvrs.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), csrf_token: get_csrf_token())
  end

  def status_report(conn, _params) do
    render(conn, "status_report.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
  end

  def routers(conn, _params) do
    render(conn, "routers.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
  end

  def commands(conn, _params) do
    render(conn, "commands.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
  end

  def sharing(conn, _params) do
    current_user = current_user(conn)
    current_user_id = current_user.id
    render(conn, "sharing.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), users_list: get_users(current_user_id))
  end

  def sim_graph_and_details(conn, %{"sim_number" => sim_number} = _params) do
    render(conn, "sim_graph_and_details.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), sim_number: sim_number)
  end

  def my_profile(conn, _params) do
    render(conn, "my_profile.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
  end

  def sites(conn, _params) do
    current_user = current_user(conn)
    current_user_id = current_user.id
    render(conn, "sites.html", user: current_user, gravatar_url: current_user |> Map.get(:email) |> gravatar_url(secure: true), list_nvrs: list_nvrs(current_user_id), list_routers: list_routers(current_user_id), all_sims: all_sims(current_user_id))
  end

  def swagger(conn, _params) do
    current_user = current_user(conn)
    current_user_id = current_user.id
    render(conn, "swagger.html", user: current_user, gravatar_url: current_user |> Map.get(:email) |> gravatar_url(secure: true))
  end

  def sms_messages(conn, _params) do
    current_user = current_user(conn)
    current_user_id = current_user.id
    render(conn, "sms_messages.html", user: current_user, gravatar_url: current_user |> Map.get(:email) |> gravatar_url(secure: true), list_nvrs: list_nvrs(current_user_id), list_routers: list_routers(current_user_id), all_sims: all_sims(current_user_id))
  end
end