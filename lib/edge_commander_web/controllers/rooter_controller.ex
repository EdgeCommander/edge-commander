defmodule EdgeCommanderWeb.RooterController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  import EdgeCommander.Accounts, only: [current_user: 1]
  import Gravatar
  require IEx

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

  def nvrs(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "nvrs.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), csrf_token: get_csrf_token())
    else
      _ ->
        conn
        |> put_flash(:error, "You must be logged in to see that page :).")
        |> redirect(to: "/users/sign_in")
    end
  end

  def status_report(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "status_report.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
    else
      _ ->
        conn
        |> put_flash(:error, "You must be logged in to see that page :).")
        |> redirect(to: "/users/sign_in")
    end
  end

  def routers(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "routers.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
    else
      _ ->
        conn
        |> put_flash(:error, "You must be logged in to see that page :).")
        |> redirect(to: "/users/sign_in")
    end
  end

  def commands(conn, _params) do
    with %User{} <- current_user(conn) do
      render(conn, "commands.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true))
    else
      _ ->
        conn
        |> put_flash(:error, "You must be logged in to see that page :).")
        |> redirect(to: "/users/sign_in")
    end
  end

   
  

  def sim_graph_and_details(conn, %{"sim_number" => sim_number} = _params) do

    api_key = System.get_env("NEXMO_API_KEY")
    api_secret =  System.get_env("NEXMO_API_SECRET")
    to =  System.get_env("NEXMO_API_NUMBER")
    date =  Date.utc_today

    url = "https://rest.nexmo.com/search/messages?api_key=#{api_key}&api_secret=#{api_secret}&date=#{date}&to=#{to}"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
          sms_list = 
                body 
                |> Poison.decode 
                |> elem(1) 
                |> Map.get("items") 

          from =   number_with_code(sim_number)

          sms_list =  filter_sms(sms_list,from,to)

        {:error, %{status_code: 404}} ->
        # do something with a 404
    end




    with %User{} <- current_user(conn) do
      render(conn, "sim_graph_and_details.html", user: current_user(conn), gravatar_url: current_user(conn) |> Map.get(:email) |> gravatar_url(secure: true), sim_number: sim_number, sms_list: sms_list)
    else
      _ ->
        conn
        |> put_flash(:error, "You must be logged in to see that page :).")
        |> redirect(to: "/users/sign_in")
    end
  end


  defp filter_sms(list, from ,to) do
     for list = %{ "from" => from, "to" => to } <- list,
      from == from &&  to == to , do:  list
   end
 
  defp number_with_code("0" <> number), do: "353#{number}"



end
