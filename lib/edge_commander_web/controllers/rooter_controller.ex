defmodule EdgeCommanderWeb.RooterController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  import EdgeCommander.Accounts, only: [current_user: 1]
  import EdgeCommander.Devices, only: [list_nvrs: 1, list_routers: 1]
  import EdgeCommander.ThreeScraper, only: [all_sims: 0]
  import Gravatar
  require Logger

  def index(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "index.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end

  def sim_logs(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "sim_logs.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), csrf_token: get_csrf_token())
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end

  def nvrs(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "nvrs.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), csrf_token: get_csrf_token())
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end

  def status_report(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "status_report.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end

  def routers(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "routers.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end

  def commands(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "commands.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end

  def sim_graph_and_details(conn, %{"sim_number" => sim_number} = _params) do
    with %User{} <- current_user(conn) do
      render(conn, "sim_graph_and_details.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), sim_number: sim_number)
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end

  def my_profile(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "my_profile.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end

  def sites(conn, _params) do
    current_user = current_user(conn)
    with %User{} <- current_user(conn) do
      current_user_id = current_user.id
      render(conn, "sites.html", user: current_user, gravatar_url: current_user |> Map.get(:email) |> gravatar_url(secure: true), list_nvrs: list_nvrs(current_user_id), list_routers: list_routers(current_user_id), all_sims: all_sims())
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end

  def swagger(conn, _params) do
    current_user = current_user(conn)
    with %User{} <- current_user(conn) do
      current_user_id = current_user.id
      render(conn, "swagger.html", user: current_user, gravatar_url: current_user |> Map.get(:email) |> gravatar_url(secure: true), list_nvrs: list_nvrs(current_user_id), list_routers: list_routers(current_user_id), all_sims: all_sims())
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end

  def sms_messages(conn, _params) do
    current_user = current_user(conn)
    with %User{} <- current_user(conn) do
      current_user_id = current_user.id
      render(conn, "sms_messages.html", user: current_user, gravatar_url: current_user |> Map.get(:email) |> gravatar_url(secure: true), list_nvrs: list_nvrs(current_user_id), list_routers: list_routers(current_user_id), all_sims: all_sims())
    else
      _ ->
        conn
        |> redirect(to: "/")
    end
  end
end