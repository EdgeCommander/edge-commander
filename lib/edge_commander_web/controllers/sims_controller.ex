defmodule EdgeCommanderWeb.SimsController do
  use EdgeCommanderWeb, :controller
  import EdgeCommander.ThreeScraper
  import EdgeCommander.Nexmo, only: [get_message: 1, get_single_sim_messages: 2, get_last_message_details: 2, get_sms_since_last_bill: 3]
  import EdgeCommander.Accounts, only: [current_user: 1, by_api_keys: 2]
  alias EdgeCommander.Nexmo.SimMessages
  alias EdgeCommander.ThreeScraper.SimLogs
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  require Logger
  use PhoenixSwagger

  swagger_path :get_sim_logs do
    get "/v1/sims"
    summary "Returns all sims data"
    parameters do
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 200, "Success"
  end

  swagger_path :get_single_sim_data do
    get "/v1/sims/{sim_number}"
    description "Returns list of data for single sim"
    summary "Find data by sim number"
    parameters do
      sim_number :path, :string, "Sim number in given format (08xxxxxxxx)", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 200, "Success"
  end

  swagger_path :get_single_sim_sms do
    get "/v1/sims/{sim_number}/sms"
    description "Returns latest 10 sms for single sim"
    summary "Find sms by sim number"
    parameters do
      sim_number :path, :string, "Sim number in given format (08xxxxxxxx)", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 200, "Success"
  end

  swagger_path :create_chartjs_line_data do
    get "/v1/sims/{sim_number}/usage"
    description "Returns data usage in % for single sim"
    summary "Find data usage in % by sim number"
    parameters do
      sim_number :path, :string, "Sim number in given format (08xxxxxxxx)", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 200, "Success"
  end

  swagger_path :send_sms do
    post "/v1/sims/{sim_number}/sms"
    summary "Send sms to sim"
    parameters do
      sim_number :path, :string, "Sim number in given format (08xxxxxxxx)", required: true
      sms_message :query, :string, "", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 200, "Success"
  end

  def create(conn, params) do
    params = Map.merge(params, %{"datetime" => NaiveDateTime.utc_now})
    changeset = SimLogs.changeset(%SimLogs{}, params)
    case Repo.insert(changeset) do
      {:ok, site} ->
        %EdgeCommander.ThreeScraper.SimLogs{
          sim_provider: sim_provider,
          number: number,
          name: name,
          addon: addon,
          allowance: allowance,
          volume_used: volume_used,
          datetime: datetime,
          user_id: user_id,
          three_user_id: three_user_id
        } = site

        number = params["number"]
        name = params["name"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "SIM: <span>#{number}</span> with the name of <span>#{name}</span> was created.",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        conn
        |> put_status(:created)
        |> json(%{
          "sim_provider" => sim_provider,
          "number" => number,
          "name" => name,
          "addon" => addon,
          "allowance" => allowance,
          "volume_used" => volume_used,
          "datetime" => datetime,
          "user_id" => user_id,
          "three_user_id" => three_user_id
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{errors: traversed_errors})
    end
  end

  def update(conn, %{"id" => id} = params) do
    new_name = params["name"]
    records = get_sim_logs!(id)
    old_name = records.name
    records
    |> SimLogs.changeset(params)
    |> Repo.update
    |> case do
      {:ok, sim} ->
        %EdgeCommander.ThreeScraper.SimLogs{
          name: name
        } = sim

        name = params["name"]
        current_user = current_user(conn)
        logs_params = %{
        "event" => "Sim name was changed from <span>#{old_name}</span> to <span>#{new_name}</span>",
        "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        conn
        |> put_status(:created)
        |> json(%{
          "name" => name
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })   
    end
  end

  def get_single_sim_data(conn, %{"sim_number" => sim_number } = params) do
    current_user_id = Util.get_user_id(conn, params)
    logs =
      get_single_sim_by_user(sim_number, current_user_id)
      |> Enum.map(fn(number) ->
        {current_in_number, _} = number |> get_volume_used() |> String.replace(",", "") |> Float.parse()
        {allowance_in_number, _} = number |> get_allowance() |> String.replace(",", "") |> Float.parse()
        %{
          "allowance" => number |> get_allowance(),
          "volume_used_today" => number |> get_volume_used(),
          "percentage_used" =>  ensure_allowance_value(allowance_in_number, current_in_number),
          "current_in_number" => current_in_number,
          "allowance_in_number" => allowance_in_number,
          "date_of_use" => number |> Map.get(:datetime) |> Util.shift_zone()
        }
      end) |> Enum.sort(& (&1["percentage_used"] >= &2["percentage_used"]))
    conn
    |> put_status(200)
    |> json(%{
        "logs": logs
      })
  end

  def get_single_sim_name(conn, %{"sim_number" => sim_number } = params) do
    name =
      get_sim_name(sim_number)
    conn
    |> put_status(200)
    |> json(%{
        "sim_name": name
      })
  end

  def get_sim_logs(conn, params)  do
    current_user_id = Util.get_user_id(conn, params)
    logs =
      get_sim_numbers(current_user_id)
      |> Enum.map(fn(sims) ->
        id = sims.id
        number = sims.number
        name = sims.name
        bill_day = sims.bill_day
        allowance = sims.allowance
        today_volume_used = validate_value(sims.today_volume_used)
        yesterday_volume_used = validate_value(sims.yesterday_volume_used)
        three_user_id = sims.three_user_id
        datetime = sims.datetime
        sim_provider = sims.sim_provider

        {current_in_number, _} = today_volume_used |> String.replace(",", "") |> Float.parse()
        {yesterday_in_number, _} = yesterday_volume_used |> String.replace(",", "") |> Float.parse()
        {allowance_in_number, _} = allowance |> String.replace(",", "") |> Float.parse()

        last_bill_date = get_bill_date(bill_day)

        %{
          "id" => id,
          "number" => number,
          "name" => name,
          "allowance" => allowance,
          "volume_used_today" => today_volume_used,
          "volume_used_yesterday" => yesterday_volume_used,
          "percentage_used" => get_percentage_used(current_in_number , allowance_in_number),
          "current_in_number" => current_in_number,
          "yesterday_in_number" => yesterday_in_number,
          "allowance_in_number" => allowance_in_number,
          "date_of_use" => datetime |> Util.shift_zone(),
          "sim_provider" => sim_provider,
          "last_bill_date" => last_bill_date,
          "last_sms" => "Loading....",
          "last_sms_date" => "Loading....",
          "total_sms_send" => "Loading....",
          "bill_day" => bill_day
        }
      end) |> Enum.sort(& (&1["percentage_used"] >= &2["percentage_used"]))
    conn
    |> put_status(200)
    |> json(%{
        "logs": logs
      })
  end

  def last_sms_details(conn, params) do
    number = params["number"]
    current_user_id = Util.get_user_id(conn, params)
    last_sms_details = get_last_message_details(number, current_user_id)
    last_sms = get_last_sms(last_sms_details)
    last_sms_date = get_last_sms_date(last_sms_details)
    sms_details = %{
      "last_sms" => last_sms,
      "last_sms_date" => last_sms_date
    }
    conn
    |> put_status(200)
    |> json(%{
        "sms": sms_details
      })
  end

  def create_chartjs_line_data(conn, %{"sim_number" => sim_number } = params) do
    current_user_id = Util.get_user_id(conn, params)
    chartjs_data =
      sim_number
      |> get_all_records_for_sim_by_user(current_user_id)
      |> Enum.map(fn(one_record) ->
        {current_in_number, _} = one_record |> get_volume_used() |> String.replace(",", "") |> Float.parse()
        {allowance_in_number, _} = one_record |> get_allowance() |> String.replace(",", "") |> Float.parse()

        %{
          datetime: "#{shift_date(one_record.datetime)}",
          percentage_used: ensure_allowance_value(allowance_in_number, current_in_number)
        }
      end)

    conn
    |> put_status(200)
    |> json(%{
      "chartjs_data": chartjs_data
    })
  end

  def send_sms(conn, params) do
    sms_message = params["sms_message"]
    to_number = params["sim_number"]
    user_id = params["user_id"]
    nexmo_number = choose_nexmo_number(to_number)
    current_user = ensure_user_id(conn, user_id)
    url = "https://rest.nexmo.com/sms/json"
    body = Poison.encode!(%{
      "api_key": System.get_env("NEXMO_API_KEY"),
      "api_secret": System.get_env("NEXMO_API_SECRET"),
      "to": to_number |> number_without_plus_code,
      "from": nexmo_number,
      "text": sms_message
    })
    headers = [{"Content-type", "application/json"}]
    
    case HTTPoison.post(url, body, headers, []) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->

        results =
          body
          |> Poison.decode
          |> elem(1)
          |> Map.get("messages")
          |> List.first

        status_code = results |> Map.get("status")
        status_code |> save_send_sms(nexmo_number, results, sms_message, current_user)

        sim_number = params["sim_number"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "SMS: <span>#{sms_message}</span> command was sent to <span>#{sim_number}</span>",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        error_text = results |> Map.get("error-text")
        conn
        |> put_status(200)
        |> json(%{status: status_code, error_text: error_text})

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_status(404)
        |> json(%{reason: reason})
    end
  end

  defp choose_nexmo_number(number)  do
    ir_number = String.contains? number, "+353"
    if ir_number == true do
      System.get_env("NEXMO_API_IR_NUMBER")
    else
      System.get_env("NEXMO_API_UK_NUMBER")
    end
  end

  def count_total_sms(conn, params) do
    bill_day = params["bill_day"]
    number = params["number"]
    current_user_id = Util.get_user_id(conn, params)
    last_bill_date = get_bill_date(bill_day)
    total_sms = get_total_sms(number, last_bill_date, current_user_id)
    conn
    |> put_status(200)
    |> json(%{result: total_sms})
  end

  defp get_total_sms(_number, nil, _current_user_id), do: 0
  defp get_total_sms(number, last_bill_date, current_user_id), do: get_sms_since_last_bill(number, last_bill_date, current_user_id)

  defp save_send_sms("0", nexmo_number, results, sms_message, user_id) do
    params = %{
      to: results |> Map.get("to") |> number_with_plus_code,
      from: nexmo_number |> number_with_plus_code,
      message_id: results |> Map.get("message-id"),
      status: "Pending",
      text: sms_message,
      type: "MT",
      user_id: user_id
    }
    changeset = SimMessages.changeset(%SimMessages{}, params)
    case Repo.insert(changeset) do
      {:ok, _} -> Logger.info "SMS has been saved"
      {:error, changeset} -> Logger.info Util.parse_changeset(changeset)
    end
  end

  defp save_send_sms(_status, nexmo_number, _results, _sms_message, _user_id), do: :noop

  def receive_sms(conn, params) do
    text = params["text"]
    from_number = params["msisdn"] |> number_with_plus_code

    is_new_sim(conn, text, from_number)
    to_number = params["to"] |> number_with_plus_code
    users = get_all_users_by_number(from_number)
    Enum.each(users, fn(user_id) ->
      params = %{
        to: to_number,
        from: from_number,
        message_id: params["messageId"],
        status: "Received",
        text: params["text"],
        type: "MO",
        user_id: user_id,
        delivery_datetime: NaiveDateTime.utc_now
      }

      changeset = SimMessages.changeset(%SimMessages{}, params)
      case Repo.insert(changeset) do
        {:ok, _} -> Logger.info "SMS has been saved"
        send_daily_sms_alert(from_number, user_id)
        send_monthly_sms_alert(from_number, user_id)
        {:error, changeset} -> Logger.info Util.parse_changeset(changeset)
      end
    end)
    conn
    |> json(%{void: 0})
  end

  defp is_new_sim(conn, message, number) do
    body = String.split(message , ",")
    is_add = Enum.at(body, 0) =~ "add"
    check_sms_command(is_add, conn, body, number)
  end

  defp check_sms_command(false, _conn, _body, _number), do: :noop
  defp check_sms_command(true, conn, body, number) do

    sim_name = String.replace(Enum.at(body, 0), "add ", "")
    sim_provider = Enum.at(body, 1)
    addon = "Unknown"
    allowance = "0"
    volume_used = "0"
    user_id = 1
    three_user_id = 0
    datetime = NaiveDateTime.utc_now
    params = %{
      "sim_provider" => sim_provider,
      "number" => number,
      "name" => sim_name,
      "addon" => addon,
      "allowance" => allowance,
      "volume_used" => volume_used,
      "user_id" => user_id,
      "three_user_id" => three_user_id,
      "datetime" => datetime
    }
    number_exist = get_last_record_for_number(number)
    ensure_number_exist(number_exist, conn, params)
  end

  defp ensure_number_exist(nil, conn, params) do
    changeset = SimLogs.changeset(%SimLogs{}, params)
    case Repo.insert(changeset) do
      {:ok, _site} ->
        %EdgeCommander.ThreeScraper.SimLogs{
          sim_provider: params["sim_provider"],
          number: params["number"],
          name: params["name"],
          addon: params["addon"],
          allowance: params["allowance"],
          volume_used: params["volume_used"],
          datetime: params["datetime"],
          user_id: params["user_id"],
          three_user_id: params["three_user_id"]
        }
        number = params["number"]
        name = params["name"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "SIM: <span>#{number}</span> with the name of <span>#{name}</span> was created using SMS command.",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)
        conn
        |> json(%{void: 0})
      {:error, _changeset} ->
        conn
        |> put_status(400)
    end
  end
  defp ensure_number_exist(_, _conn, _params), do: :noop

  defp send_daily_sms_alert(number, current_user_id) do
    current_day_date = get_current_date()
    total_sms = get_total_sms(number, current_day_date, current_user_id)
    send_daily_alert_email(number, total_sms)
  end

  defp send_monthly_sms_alert(number, current_user_id) do
    bill_day = get_sim_bill_day(number) |> Map.get(:bill_day)
    last_bill_date = get_bill_date(bill_day)
    total_monthly_sms = get_total_sms(number, last_bill_date, current_user_id)
    send_monthly_alert_email(number, total_monthly_sms, last_bill_date)
  end

  def daily_sms_count(conn, params) do
    number = params["number"]
    current_user_id = Util.get_user_id(conn, params)
    current_day_date = get_current_date()
    total_sms = get_total_sms(number, current_day_date, current_user_id)
    conn
    |> put_status(200)
    |> json(%{result: total_sms})
  end

  def delivery_receipt(conn, params) do
    get_message(params["messageId"])
    |> ensure_message(params)
    conn
    |> json(%{void: 0})
  end

  def get_single_sim_sms(conn, %{"sim_number" => sim_number} = params) do
    current_user_id = Util.get_user_id(conn, params)
    single_sim_sms =
      get_single_sim_messages(sim_number, current_user_id)
      |> Enum.map(fn(sms) ->
        %{
          inserted_at: sms.inserted_at |> Util.shift_zone(),
          type: sms.type,
          status: sms.status,
          text: sms.text,
          delivery_datetime: sms.delivery_datetime |> validate_dateTime
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        "single_sim_sms": single_sim_sms
      })
  end

  defp validate_dateTime(nil),  do: ""
  defp validate_dateTime(delivery_datetime),  do: delivery_datetime |> Util.shift_zone()

  defp ensure_user_id(conn, nil), do: conn.assigns[:current_user] |> Map.get(:id)
  defp ensure_user_id(_conn, user_id), do: user_id

  defp ensure_message(nil, _params), do: Logger.info "Message didn't send from EC."
  defp ensure_message(message_id, params) do
    message_id
    |> SimMessages.changeset(%{
      status: params["status"],
      delivery_datetime: params["status"] |> get_date_time
    })
    |> Repo.update
    |> case do
      {:ok, _} -> Logger.info "SMS Status has been Updated"
      {:error, changeset} -> Logger.info Util.parse_changeset(changeset)
    end
  end

  defp get_date_time("delivered"), do: NaiveDateTime.utc_now
  defp get_date_time(_), do: ""

  defp number_with_plus_code(number), do: "+#{number}"
  defp number_without_plus_code("+" <> number), do: "#{number}"

  defp ensure_allowance_value(0.0, _current_in_number), do: 0
  defp ensure_allowance_value(allowance_in_number, current_in_number) do
    (current_in_number / allowance_in_number * 100) |> Float.round(3)
  end

  defp shift_date(datetime) do
    datetime
    |> Calendar.Strftime.strftime("%Y-%m-%d")
    |> elem(1)
  end

  defp get_volume_used(log) do
    log.volume_used
  end

  defp get_name(log) do
    log.name
  end

  defp get_allowance(log) do
    log.allowance
  end

  defp ensure_number(number) when number >= 1 and number <= 9, do: "0#{number}"
  defp ensure_number(number), do: number

  defp get_month(current_day, bill_day, current_month) when current_day > bill_day, do: ensure_number(current_month)
  defp get_month(_current_day, _bill_day, current_month), do: ensure_number(current_month - 1)

  defp get_last_sms_date(nil), do: "-"
  defp get_last_sms_date(last_sms_details), do: last_sms_details |> Map.get(:inserted_at) |> Util.shift_zone()

  defp get_last_sms(nil), do: "-"
  defp get_last_sms(last_sms_details), do: last_sms_details |> Map.get(:text)

  defp get_bill_date(nil), do: nil
  defp get_bill_date("null"), do: nil
  defp get_bill_date(day) do
    day = check_data_type(day)
    bill_day = day  |> ensure_number
    year = DateTime.utc_now |> Map.fetch!(:year)
    current_month = DateTime.utc_now |> Map.fetch!(:month)
    current_day = DateTime.utc_now |> Map.fetch!(:day)
    month = get_month(current_day, bill_day, current_month)
    date_time = "#{year}-#{month}-#{bill_day} 00:00:00"
    {:ok, date} = NaiveDateTime.from_iso8601(date_time)
    date
  end

  defp check_data_type(number) when is_bitstring(number) do
    {day, ""} = Integer.parse(number)
    day
  end
  defp check_data_type(day), do: day

  defp get_percentage_used(current_in_number, allowance_in_number) when allowance_in_number > 0  do
    (current_in_number / allowance_in_number * 100) |> Float.round(3)
  end
  defp get_percentage_used(_current_in_number, _allowance_in_number), do: 0

  defp validate_value(nil), do: "0"
  defp validate_value(value), do: value

  defp get_current_date() do
    current_year = DateTime.utc_now |> Map.fetch!(:year)
    month = DateTime.utc_now |> Map.fetch!(:month)
    day = DateTime.utc_now |> Map.fetch!(:day)
    current_month = ensure_number(month)
    current_day = ensure_number(day)
    date_time = "#{current_year}-#{current_month}-#{current_day} 00:00:00"
    {:ok, date} = NaiveDateTime.from_iso8601(date_time)
    date
  end

  defp convert_date_format(date) do
    year = date.year
    month = date.month |> ensure_number
    day = date.day |> ensure_number
    date = "#{day}-#{month}-#{year}"
  end

  defp send_daily_alert_email(number, total_sms) when total_sms > 6 do
    current_day_date = get_current_date()
    current_date = convert_date_format(current_day_date)
    EdgeCommander.Commands.get_active_sms_usage_rules()
    |> Enum.map(fn(recipients) ->
      EdgeCommander.EcMailer.daily_sms_usage_alert(current_date, recipients, number, total_sms)
      Logger.info "Daily SMS usage email alert has been sent."
  end)
  end
  defp send_daily_alert_email(_number, _total_sms), do: :noop

  defp send_monthly_alert_email(number, total_sms, bill_date) when total_sms > 190 do
    last_bill_date = convert_date_format(bill_date)
    EdgeCommander.Commands.get_monthly_sms_usage_rules()
    |> Enum.map(fn(recipients) ->
        EdgeCommander.EcMailer.monthly_sms_usage_alert(last_bill_date, recipients, number, total_sms)
        Logger.info "Monthly SMS usage email alert has been sent."
    end)
  end
  defp send_monthly_alert_email(_number, _total_sms, _last_bill_date), do: :noop
end