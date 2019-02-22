defmodule EdgeCommanderWeb.DashboardController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  alias EdgeCommander.Accounts.Guardian
  alias EdgeCommander.ThreeScraper.Records
  alias EdgeCommander.Devices
  alias EdgeCommander.Sites
  import EdgeCommander.Accounts, only: [current_user: 1]
  import EdgeCommander.Nexmo, only: [get_total_messages: 3]
  import EdgeCommander.Solar, only: [get_readings: 3, get_maximum_voltage: 2, get_minimum_voltage: 2]

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

  def total_sims(conn, _params) do
    total_sims = Records.get_sims() |> Enum.count
    conn
    |> put_status(:ok)
    |> json(%{
      "total_sims" => total_sims
    })
  end

  def total_nvrs(conn, _params) do
    total_nvrs = Devices.list_nvrs() |> Enum.count
    conn
      |> put_status(:ok)
      |> json(%{
        "total_nvrs" => total_nvrs
      })
  end

  def total_routers(conn, _params) do
    total_routers = Devices.list_routers |> Enum.count
    conn
      |> put_status(:ok)
      |> json(%{
        "total_routers" => total_routers
      })
  end

  def total_sites(conn, _params) do
    total_sites = Sites.list_sites() |> Enum.count
    conn
      |> put_status(:ok)
      |> json(%{
        "total_sites" => total_sites
      })
  end

  def weekly_sms_overview(conn, _params) do
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
        pending_sms =  get_total_messages(date, date, "accepted")
        delivered_sms =  get_total_messages(date, date, "delivered")
        received_sms =  get_total_messages(date, date, "Received")
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
    battery_id = params["battery_id"]

    range = Date.range(from_date, to_date)
    dates = Enum.to_list(range)
    records =
      dates
      |> Enum.map(fn(value) ->
        year = value.year
        month = value.month |> ensure_number
        day = value.day |> ensure_number
        date = "#{year}-#{month}-#{day}"
        max_value = get_maximum_voltage(date, battery_id) |> convert_units
        min_value = get_minimum_voltage(date, battery_id) |> convert_units
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
