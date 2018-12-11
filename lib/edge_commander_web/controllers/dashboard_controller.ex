defmodule EdgeCommanderWeb.DashboardController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  alias EdgeCommander.Accounts.Guardian
  alias EdgeCommander.ThreeScraper
  alias EdgeCommander.Devices
  alias EdgeCommander.Util
  alias EdgeCommander.Sites
  import EdgeCommander.Accounts, only: [current_user: 1]
  import EdgeCommander.Sharing, only: [member_by_token: 1]
  import EdgeCommander.Nexmo, only: [get_total_messages: 4]
  import EdgeCommander.Solar, only: [list_battery_records: 2]

  def sign_up(conn, _params) do
    with %User{} <- current_user(conn) do
    conn
    |> redirect(to: "/dashboard")
    else
      _ ->
        render(conn, "sign_up.html", csrf_token: get_csrf_token())
    end
  end

  def sign_in(conn, _params) do
    with %User{} <- current_user(conn) do
      conn
      |> redirect(to: "/dashboard")
    else
      _ ->
        render(conn, "sign_in.html", csrf_token: get_csrf_token())
    end
  end

  def forgot_password(conn, _params) do
    with %User{} <- current_user(conn) do
    conn
    |> redirect(to: "/dashboard")
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

  def sharing_confirm(conn, %{"token" => token} = _params) do
    user_details = member_by_token(token)
    if user_details.member_id != 0 do
      conn
      |> redirect(to: "/dashboard")
      else
        render(conn, "sign_up_on_sharing.html", user_details: user_details)
    end
  end

  def total_sims(conn, params) do
    current_user = current_user(conn)
    current_user_id = Util.get_user_id(conn, params)
    total_sims = ThreeScraper.get_sim_numbers(current_user_id) |> Enum.count
    conn
    |> put_status(:ok)
    |> json(%{
      "total_sims" => total_sims
    })
  end

  def total_nvrs(conn, params) do
    current_user = current_user(conn)
    current_user_id = Util.get_user_id(conn, params)
    total_nvrs = Devices.list_nvrs(current_user_id) |> Enum.count
    conn
      |> put_status(:ok)
      |> json(%{
        "total_nvrs" => total_nvrs
      })
  end

  def total_routers(conn, params) do
    current_user = current_user(conn)
    current_user_id = Util.get_user_id(conn, params)
    total_routers = Devices.list_routers(current_user_id) |> Enum.count
    conn
      |> put_status(:ok)
      |> json(%{
        "total_routers" => total_routers
      })
  end

  def total_sites(conn, params) do
    current_user = current_user(conn)
    current_user_id = Util.get_user_id(conn, params)
    total_sites = Sites.list_sites(current_user_id) |> Enum.count
    conn
      |> put_status(:ok)
      |> json(%{
        "total_sites" => total_sites
      })
  end

  def weekly_sms_overview(conn, params) do
    current_user = current_user(conn)
    current_user_id = Util.get_user_id(conn, params)
    to_date = Date.utc_today
    from_date = Date.add(to_date, -7)

    range = Date.range(from_date, to_date)
    dates = Enum.to_list(range)
    sms_history =
      dates
      |> Enum.map(fn(value) ->
        month = value.month |> ensure_number
        day = value.day |> ensure_number
        date = "#{value.year}-#{month}-#{day}"
        pending_sms =  get_total_messages(date, date, current_user_id, "accepted")
        delivered_sms =  get_total_messages(date, date, current_user_id, "delivered")
        received_sms =  get_total_messages(date, date, current_user_id, "Received")
        %{
          date: date,
          pending_sms: pending_sms,
          delivered_sms: delivered_sms,
          received_sms: received_sms
        }
      end)
    conn
    |> put_status(:ok)
    |> json(%{
      "sms_history" => sms_history
    })
  end

  def daily_batery_voltages(conn, params) do
    from_date = params["from_date"]
    to_date = params["to_date"]
      time_list =
        list_battery_records(from_date, to_date)
        |> Enum.map(fn(data) ->
         data.datetime
      end)

      voltage_list =
        list_battery_records(from_date, to_date)
        |> Enum.map(fn(data) ->
          data.voltage
        end)

      voltages_history = %{
        "date" => "",
        "time_list" => time_list,
        "voltage_list" => voltage_list
      }

      conn
      |> put_status(:ok)
      |> json(%{
        "voltages_history" => voltages_history
      })
  end

  defp ensure_number(number) when number >= 1 and number <= 9, do: "0#{number}"
  defp ensure_number(number), do: number
end
