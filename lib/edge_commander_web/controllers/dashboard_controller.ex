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
  import EdgeCommander.Solar, only: [get_readings: 3, get_maximum_voltage: 1, get_minimum_voltage: 1]

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
    current_user_id = Util.get_user_id(conn, params)
    total_sims = ThreeScraper.get_sim_numbers(current_user_id) |> Enum.count
    conn
    |> put_status(:ok)
    |> json(%{
      "total_sims" => total_sims
    })
  end

  def total_nvrs(conn, params) do
    current_user_id = Util.get_user_id(conn, params)
    total_nvrs = Devices.list_nvrs(current_user_id) |> Enum.count
    conn
      |> put_status(:ok)
      |> json(%{
        "total_nvrs" => total_nvrs
      })
  end

  def total_routers(conn, params) do
    current_user_id = Util.get_user_id(conn, params)
    total_routers = Devices.list_routers(current_user_id) |> Enum.count
    conn
      |> put_status(:ok)
      |> json(%{
        "total_routers" => total_routers
      })
  end

  def total_sites(conn, params) do
    current_user_id = Util.get_user_id(conn, params)
    total_sites = Sites.list_sites(current_user_id) |> Enum.count
    conn
      |> put_status(:ok)
      |> json(%{
        "total_sites" => total_sites
      })
  end

  def weekly_sms_overview(conn, params) do
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
    battery_id = params["battery_id"]
      time_list =
        get_readings(from_date, to_date, battery_id)
        |> Enum.map(fn(data) ->
         data.datetime
      end)

      battery_voltages =
        get_readings(from_date, to_date, battery_id)
        |> Enum.map(fn(data) ->
          data.voltage |> convert_units
        end)

      panel_voltages =
        get_readings(from_date, to_date, battery_id)
        |> Enum.map(fn(data) ->
          data.vpv_value |> convert_units
        end)

      voltages_history = %{
        "date" => "",
        "time_list" => time_list,
        "battery_voltages" => battery_voltages,
        "panel_voltages" => panel_voltages
      }

      conn
      |> put_status(:ok)
      |> json(%{
        "voltages_history" => voltages_history
      })
  end


  def battery_voltages_summary(conn, params) do
    from_date = Date.from_iso8601!(params["from_date"])
    to_date = Date.from_iso8601!(params["to_date"])

    range = Date.range(from_date, to_date)
    dates = Enum.to_list(range)
    records =
      dates
      |> Enum.map(fn(value) ->
        year = value.year
        month = value.month |> ensure_number
        day = value.day |> ensure_number
        date = "#{year}-#{month}-#{day}"
        max_value = get_maximum_voltage(date) |> convert_units
        min_value = get_minimum_voltage(date) |> convert_units
        %{
          date: date,
          max_value: max_value,
          min_value: min_value
        }
      end)

    conn
    |> put_status(:ok)
    |> json(%{
      "records" => records
    })
  end

  defp ensure_number(number) when number >= 1 and number <= 9, do: "0#{number}"
  defp ensure_number(number), do: number

  defp convert_units(nil), do: 0
  defp convert_units(value) do
    value / 1000
  end
end
