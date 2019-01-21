defmodule EdgeCommanderWeb.SimsController do
  use EdgeCommanderWeb, :controller
  import EdgeCommander.ThreeScraper.Records
  import EdgeCommander.Nexmo, only: [get_message: 1, get_single_sim_messages: 2, get_sms_count: 2]
  import EdgeCommander.Accounts, only: [current_user: 1]
  alias EdgeCommander.Nexmo.SimMessages
  alias EdgeCommander.ThreeScraper.SimLogs
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  alias ThreeScraper.Scraper
  alias EdgeCommander.ThreeScraper.Records
  alias EdgeCommander.ThreeScraper.Sims
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
        add_to_sims_on_sms_command(params)
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
      {:ok, _sim} ->
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
        logs: logs
      })
  end

  def get_single_sim_name(conn, %{"sim_number" => sim_number } = _params) do
    sim_records = Records.get_single_sim(sim_number)
    conn
    |> put_status(200)
    |> json(%{
        sim_name: sim_records.name
      })
  end

  def get_sim_logs(conn, params)  do
    current_user_id = Util.get_user_id(conn, params)
    logs =
      Records.get_sims(current_user_id)
      |> Enum.map(fn(sim) ->
        %{
          "id" => sim.id,
          "number" => sim.number,
          "name" => sim.name,
          "addon" => sim.addon,
          "allowance" => sim.allowance,
          "volume_used" => sim.volume_used,
          "volume_used_yesterday" => sim.yesterday_volume_used,
          "percentage_used" => sim.percentage_used,
          "remaning_days" => sim.remaning_days,
          "last_log_reading_at" => sim.last_log_reading_at,
          "sim_provider" => sim.sim_provider,
          "last_bill_date" => sim.last_bill_date,
          "last_sms" => sim.last_sms,
          "last_sms_date" => sim.last_sms_date,
          "sms_since_last_bill" => sim.sms_since_last_bill,
          "status" => sim.status
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
      logs: logs
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
      chartjs_data: chartjs_data
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
      api_key: System.get_env("NEXMO_API_KEY"),
      api_secret: System.get_env("NEXMO_API_SECRET"),
      to: to_number |> number_without_plus_code,
      from: nexmo_number,
      text: sms_message
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
         update_last_sms_details(params)
        send_daily_sms_alert(from_number)
        send_monthly_sms_alert(from_number)
        {:error, changeset} -> Logger.info Util.parse_changeset(changeset)
      end
    end)
    conn
    |> json(%{void: 0})
  end

  defp choose_nexmo_number(number)  do
    ir_number = String.contains? number, "+353"
    if ir_number == true do
      System.get_env("NEXMO_API_IR_NUMBER")
    else
      System.get_env("NEXMO_API_UK_NUMBER")
    end
  end

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
  defp save_send_sms(_status, _nexmo_number, _results, _sms_message, _user_id), do: :noop

  defp update_last_sms_details(params) do
    number = params[:from]
    last_sms = params[:text]
    last_sms_date = params[:delivery_datetime] |> Util.date_time_to_string
    sim_record = Records.get_single_sim(number)
    last_bill_date = sim_record.last_bill_date <> " 00:00:00" |> NaiveDateTime.from_iso8601!()
    sms_since_last_bill = Scraper.get_total_sms(number, last_bill_date)
    params = %{
      last_sms: last_sms,
      last_sms_date: last_sms_date,
      sms_since_last_bill: sms_since_last_bill
    }
    number_already_exist(sim_record, params)
  end

  def number_already_exist(nil, _params), do: :noop
  def number_already_exist(sim_record, params) do
    Records.get_sim!(sim_record.id)
    |> Sims.changeset(params)
    |> Repo.update
    |> case do
      {:ok, _sim} ->
        Logger.info "SIM number has been updated"
      {:error, _changeset} ->
        Logger.error "SIM number did not updated due to failure."
    end
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
    allowance = "-1.0"
    volume_used = "-1.0"
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
        add_to_sims_on_sms_command(params)
        conn
        |> json(%{void: 0})
      {:error, _changeset} ->
        conn
        |> put_status(400)
    end
  end
  defp ensure_number_exist(_, _conn, _params), do: :noop

  defp add_to_sims_on_sms_command(params) do
    number = params["number"]
    sims_records = Records.get_single_sim(number)
    volume_usage = Records.get_yesterday_usage(number)
    yesterday_volume_used = volume_usage |> Scraper.ensure_yesterday_volume

    allowance_in_number = params["allowance"] |> Util.convert_string_float
    current_in_number = params["volume_used"] |> Util.convert_string_float
    yesterday_in_number = yesterday_volume_used |> Util.convert_string_float

    percentage_used = Scraper.get_percentage_used(current_in_number, allowance_in_number)
    remaning_days = Scraper.get_remaing_days(current_in_number, allowance_in_number, yesterday_in_number)

    last_bill_date = "-"
    last_sms_records = Scraper.last_sms_details(number)
    sms_since_last_bill = Scraper.get_total_sms(number, last_bill_date)

    params = %{
      number: number,
      name: params["name"],
      addon: params["addon"],
      allowance: params["allowance"],
      volume_used: params["volume_used"],
      sim_provider: params["sim_provider"],
      yesterday_volume_used: yesterday_volume_used,
      percentage_used: percentage_used,
      remaning_days: remaning_days,
      last_log_reading_at: params["datetime"] |> Util.shift_zone() |> Util.date_time_to_string,
      last_bill_date: last_bill_date ,
      last_sms: last_sms_records.last_sms,
      last_sms_date: last_sms_records.last_sms_date |> Util.date_time_to_string,
      sms_since_last_bill: sms_since_last_bill,
      status: "Not Found.",
      user_id: params["user_id"],
      three_user_id: params["three_user_id"]
    }
    Scraper.number_already_exist(sims_records, params)
  end

  defp send_daily_sms_alert(number) do
    current_day_date = Util.get_current_date()
    total_sms = get_sms_count(number, current_day_date)
    daily_sms_rules = EdgeCommander.Commands.get_daily_sms_usage_rules_list()
     Enum.each(daily_sms_rules, fn(rule) ->
      variable = rule.variable
      value = rule.value
      params = %{
        number: number,
        total_sms: total_sms,
        variable: variable,
        value: value,
        alert_for: "daily_sms_alert"
      }
      Util.condition_for_sms_alert(params)
     end)
  end

  defp send_monthly_sms_alert(number) do
    last_bill_date =  Records.get_last_bill_date(number)
    is_valid_then_send_email(last_bill_date, number)
  end

  defp is_valid_then_send_email("-", _number), do: Logger.error "Monthly email did't send due to invalid last bill date."
  defp is_valid_then_send_email(bill_date, number) do
    last_bill_date = bill_date <> " 00:00:00" |> NaiveDateTime.from_iso8601!()
    total_monthly_sms = get_sms_count(number, last_bill_date)
    monthly_sms_rules = EdgeCommander.Commands.get_monthly_sms_usage_rules_list()
    Enum.each(monthly_sms_rules, fn(rule) ->
      variable = rule.variable
      value = rule.value
      params = %{
        number: number,
        total_sms: total_monthly_sms,
        last_bill_date: last_bill_date,
        variable: variable,
        value: value,
        alert_for: "monthly_sms_alert"
      }
      Util.condition_for_sms_alert(params)
    end)
  end

  def daily_sms_count(conn, params) do
    number = params["number"]
    current_day_date = Util.get_current_date()
    total_sms = get_sms_count(number, current_day_date)
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
        single_sim_sms: single_sim_sms
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

  defp get_allowance(log) do
    log.allowance
  end
end