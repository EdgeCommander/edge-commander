defmodule EdgeCommanderWeb.SimsController do
  use EdgeCommanderWeb, :controller
  import EdgeCommander.ThreeScraper.Records
  import EdgeCommander.Nexmo, only: [get_last_message_details: 1, get_message: 1, get_single_sim_messages: 1, get_sms_count: 2]
  import EdgeCommander.Accounts, only: [current_user: 1, get_current_resource: 1]
  alias EdgeCommander.Nexmo.SimMessages
  alias EdgeCommander.ThreeScraper.SimLogs
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  alias ThreeScraper.Scraper
  alias EdgeCommander.ThreeScraper.Records
  alias EdgeCommander.ThreeScraper.Sims
  require Logger
  require IEx
  use PhoenixSwagger

  swagger_path :create do
    post "/v1/sims"
    summary "Add a new sim"
    parameters do
      number :query, :string, "", required: true
      name :query, :string, "", required: true
      sim_provider :query, :string, "", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 201, "Success"
  end

  swagger_path :get_all_sims_by_users do
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
    get "/v1/sims/{number}"
    description "Returns details for single sim"
    summary "Find Single sim data by sim number"
    parameters do
      number :path, :string, "Sim number in given format (+353xxxxxxxx)", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 200, "Success"
  end

  swagger_path :get_single_sim_sms do
    get "/v1/sims/{number}/sms"
    description "Returns latest 10 sms for single sim"
    summary "Find sms by sim number"
    parameters do
      number :path, :string, "Sim number in given format (+353xxxxxxxx)", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 200, "Success"
  end

  swagger_path :send_sms do
    post "/v1/sims/{number}/sms"
    summary "Send sms to sim"
    parameters do
      number :path, :string, "Sim number in given format (+353xxxxxxxx)", required: true
      sms_message :query, :string, "", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 200, "Success"
  end

  swagger_path :update do
    patch "/v1/sims/{id}"
    summary "Update sim by ID"
    parameters do
      id :path, :string, "ID of sim that needs to be updated", required: true
      name :query, :string, "Updated name of the sim"
      number :query, :string, "Updated number of the sim"
      sim_provider :query, :string, "Updated sim provider of the sim"
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 201, "Success"
  end

  swagger_path :delete_sim do
    delete "/v1/sims/{id}"
    summary "Delete sim by ID"
    parameters do
      id :path, :string, "Sim id to delete", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "sims"
    response 200, "Success"
  end

  def create(conn, params) do
    current_user = get_current_resource(conn)
    has_addon = Map.has_key?(params, "addon")
    params = Map.merge(ensure_params(has_addon, params), %{"datetime" => NaiveDateTime.utc_now, "user_id" => current_user.id})
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

  defp ensure_params(false, params) do
    %{      
      "addon" => "Unknown",
      "allowance" => "-1.0",
      "name" => params["name"],
      "number" => params["number"],
      "sim_provider" => params["sim_provider"],
      "three_user_id" => 0,
      "volume_used" => "-1.0"
    }
  end
  defp ensure_params(true, params), do: params

  def update(conn, %{"id" => id} = params) do
    new_name = params["name"]
    new_number = params["number"]
    new_sim_provider = params["sim_provider"]
    records = get_sim!(id)
    old_name = records.name
    old_number = records.number
    old_sim_provider = records.sim_provider
    records
    |> Sims.changeset(params)
    |> Repo.update
    |> case do
      {:ok, sim} ->
        name = params["name"]
        current_user = get_current_resource(conn)
        event = "<span>Sim Edit: </span> Old => [<strong>Name: </strong>#{old_name}, <strong>Number: </strong> #{old_number}, <strong>Provider:</strong> #{old_sim_provider}], New => [<strong>Name: </strong>#{new_name}, <strong>Number: </strong> #{new_number}, <strong>Provider:</strong> #{new_sim_provider}]"
        logs_params = %{
        "event" => event,
        "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)
        conn
        |> put_status(:created)
        |> json(%{
          "name" => sim.name,
          "number" => sim.number,
          "sim_provider" => sim.sim_provider
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })   
    end
  end

  def get_single_sim_data(conn, %{"number" => sim_number } = _params) do
    sim_records = Records.get_single_sim(sim_number)
    conn
    |> put_status(200)
    |> json(%{
        number: sim_records.number,
        name: sim_records.name,
        addon: sim_records.addon,
        allowance: sim_records.allowance,
        volume_used: sim_records.volume_used,
        sim_provider: sim_records.sim_provider,
        yesterday_volume_used: sim_records.yesterday_volume_used,
        percentage_used: sim_records.percentage_used,
        remaning_days: sim_records.remaning_days,
        last_log_reading_at: sim_records.last_log_reading_at,
        last_bill_date: sim_records.last_bill_date,
        last_sms: sim_records.last_sms,
        last_sms_date: sim_records.last_sms_date,
        sms_since_last_bill: sim_records.sms_since_last_bill,
        status: sim_records.status,
        user_id: sim_records.user_id,
        three_user_id: sim_records.three_user_id
      })
  end

  def get_all_sims(conn, _params)  do
    sims =
      Records.get_sims
      |> Enum.map(fn(sim) ->
        %{
          "number" => sim.number,
          "name" => sim.name
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
      sims: sims
    })
  end

  def get_all_sims_by_users(conn, params) do
    user_id = Util.get_user_id(conn, params)
    sims =
      Records.get_sims_by_user(user_id)
      |> Enum.map(fn(sim) ->
        %{
          "id" => sim.id,
          "number" => sim.number,
          "name" => sim.name,
          "addon" => sim.addon,
          "allowance" => sim.allowance,
          "volume_used" => sim.volume_used,
          "sim_provider" => sim.sim_provider,
          "yesterday_volume_used" => sim.yesterday_volume_used,
          "percentage_used" => sim.percentage_used,
          "remaning_days" => sim.remaning_days,
          "last_log_reading_at" => sim.last_log_reading_at,
          "last_bill_date" => sim.last_bill_date,
          "last_sms" => sim.last_sms,
          "last_sms_date" => sim.last_sms_date,
          "sms_since_last_bill" => sim.sms_since_last_bill,
          "status" => sim.status,
          "user_id" => sim.user_id,
          "three_user_id" => sim.three_user_id,
        }
      end)

    conn
    |> put_status(200)
    |> json(%{
        sims: sims
      })
  end

  def get_sims_list(conn, params)  do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = "select * from sims as sm Where lower(sm.name) like lower('%#{search}%') OR lower(sm.number) like lower('%#{search}%') OR lower(sm.sim_provider) like lower('%#{search}%') #{add_sorting(column, order)}"
    models = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map models.columns, &(String.to_atom(&1))
    roles = Enum.map models.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = models.num_rows
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      case total_records <= 0 do
        true -> []
        _ ->
          Enum.reduce(display_start..index_end, [], fn i, acc ->
            sim = Enum.at(roles, i)
            sm = %{
              id: sim[:id],
              number: sim[:number],
              name: sim[:name],
              addon: sim[:addon],
              allowance: sim[:allowance],
              volume_used: sim[:volume_used]  |> ensure_valid_data,
              yesterday_volume_used: sim[:yesterday_volume_used] |> ensure_valid_data,
              percentage_used: sim[:percentage_used] |> ensure_valid_data,
              remaning_days: sim[:remaning_days],
              last_log_reading_at: sim[:last_log_reading_at],
              sim_provider: sim[:sim_provider],
              last_bill_date: sim[:last_bill_date],
              last_sms: sim[:last_sms],
              last_sms_date: sim[:last_sms_date],
              sms_since_last_bill: sim[:sms_since_last_bill],
              status: sim[:status],
              three_user_id: sim[:three_user_id]
            }
            acc ++ [sm]
          end)
      end

    records = %{
      data: (if total_records < 1, do: [], else: data),
      total: total_records,
      per_page: display_length,
      from: display_start,
      to: index_end,
      current_page: String.to_integer(params["page"]),
      last_page: last_page,
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/sims/data/json?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/sims/data/json?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("number", order), do: "ORDER BY number #{order}"
  defp add_sorting("name", order), do: "ORDER BY addon #{order}"
  defp add_sorting("addon", order), do: "ORDER BY name #{order}"
  defp add_sorting("allowance", order), do: "ORDER BY allowance #{order}"
  defp add_sorting("volume_used", order), do: "ORDER BY volume_used #{order}"
  defp add_sorting("yesterday_volume_used", order), do: "ORDER BY yesterday_volume_used #{order}"
  defp add_sorting("percentage_used", order), do: "ORDER BY percentage_used #{order}"
  defp add_sorting("remaning_days", order), do: "ORDER BY remaning_days #{order}"
  defp add_sorting("last_log_reading_at", order), do: "ORDER BY last_log_reading_at #{order}"
  defp add_sorting("sim_provider", order), do: "ORDER BY sim_provider #{order}"
  defp add_sorting("last_bill_date", order), do: "ORDER BY last_bill_date #{order}"
  defp add_sorting("last_sms", order), do: "ORDER BY last_sms #{order}"
  defp add_sorting("last_sms_date", order), do: "ORDER BY last_sms_date #{order}"
  defp add_sorting("sms_since_last_bill", order), do: "ORDER BY sms_since_last_bill #{order}"
  defp add_sorting("status", order), do: "ORDER BY status #{order}"

  def ensure_valid_data(-1.0), do: "-"
  def ensure_valid_data("-1.0"), do: "-"
  def ensure_valid_data(value), do: value

  def delete_sim(conn, %{"id" => id} = _params) do
    current_user = get_current_resource(conn)
    records = Records.get_sim!(id)
    records
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.ThreeScraper.Sims{}} ->
        conn
        |> put_status(200)
        |> json(%{
          deleted: true
        })
        name = records.name
        logs_params = %{
          "event" => "Sims: <span>#{name}</span> was deleted.",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  def send_sms(conn, params) do
    current_user = get_current_resource(conn)
    sms_message = params["sms_message"]
    to_number = params["number"]
    user_id = current_user.id
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
    sms_since_last_bill = is_valid_date(sim_record.last_bill_date, number)
    params = %{
      last_sms: last_sms,
      last_sms_date: last_sms_date,
      sms_since_last_bill: sms_since_last_bill
    }
    number_already_exist(sim_record, params)
  end

  defp is_valid_date("-", _number), do: 0
  defp is_valid_date(bill_date, number)  do
    last_bill_date  = bill_date <> " 00:00:00" |> NaiveDateTime.from_iso8601!()
    get_total_sms(number, last_bill_date)
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
    number_exist = Records.get_single_sim(number)
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
    yesterday_volume_used = "-1.0"
    percentage_used = -1
    remaning_days = "Infinity"
    last_bill_date = "-"
    last_sms_records = last_sms_details(number)
    sms_since_last_bill = get_total_sms(number, last_bill_date)

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
    sim_number_already_exist(sims_records, params)
  end

  def last_sms_details(number) do
    last_sms_details = get_last_message_details(number)
    last_sms = get_last_sms(last_sms_details)
    last_sms_date = get_last_sms_date(last_sms_details)
     %{
      last_sms: last_sms,
      last_sms_date: last_sms_date
    }
  end

  defp get_last_sms(nil), do: "-"
  defp get_last_sms(last_sms_details), do: last_sms_details |> Map.get(:text)

  defp get_last_sms_date(nil), do: "-"
  defp get_last_sms_date(last_sms_details), do: last_sms_details |> Map.get(:inserted_at) |> Util.shift_zone()

  defp get_total_sms(_number, "-"), do: 0
  defp get_total_sms(number, last_bill_date), do: get_sms_count(number, last_bill_date)

  defp sim_number_already_exist(nil, params) do
    changeset = Sims.changeset(%Sims{}, params)
    case Repo.insert(changeset) do
    {:ok, _logs} ->
      Logger.info "SIM number has been saved"
    {:error, _changeset} ->
      Logger.error "SIM number did not saved due to failure."
    end
  end

  defp sim_number_already_exist(already_exist, params) do
    id = already_exist.id
    Records.get_sim!(id)
    |> Sims.changeset(params)
    |> Repo.update
    |> case do
      {:ok, _sim} ->
        Logger.info "SIM number has been updated"
      {:error, _changeset} ->
        Logger.error "SIM number did not updated due to failure."
    end
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

  def get_single_sim_sms(conn, %{"number" => sim_number} = _params) do
    single_sim_sms =
      get_single_sim_messages(sim_number)
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