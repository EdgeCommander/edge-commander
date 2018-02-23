defmodule EdgeCommanderWeb.SimsController do
  use EdgeCommanderWeb, :controller
  import EdgeCommander.ThreeScraper, only: [all_sim_numbers: 0, get_last_two_days: 1, get_all_records_for_sim: 1, get_single_sim: 1]
  import EdgeCommander.Nexmo, only: [get_message: 1, get_single_sim_messages: 1]
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
      api_key :query, :string, "", required: true, default: "ea3f489a45c98eab5cc22e38db1071e8"
      api_id :query, :string, "", required: true, default: "2091d756"
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
      api_key :query, :string, "", required: true, default: "ea3f489a45c98eab5cc22e38db1071e8"
      api_id :query, :string, "", required: true, default: "2091d756"
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
      api_key :query, :string, "", required: true, default: "ea3f489a45c98eab5cc22e38db1071e8"
      api_id :query, :string, "", required: true, default: "2091d756"
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
      api_key :query, :string, "", required: true, default: "ea3f489a45c98eab5cc22e38db1071e8"
      api_id :query, :string, "", required: true, default: "2091d756"
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
      api_key :query, :string, "", required: true, default: "ea3f489a45c98eab5cc22e38db1071e8"
      api_id :query, :string, "", required: true, default: "2091d756"
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
          datetime: datetime
        } = site

        conn
        |> put_status(:created)
        |> json(%{
          "sim_provider" => sim_provider,
          "number" => number,
          "name" => name,
          "addon" => addon,
          "allowance" => allowance,
          "volume_used" => volume_used,
          "datetime" => datetime
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{errors: traversed_errors})
    end
  end

  def get_single_sim_data(conn, %{"sim_number" => sim_number } = _params) do
    logs =
      get_single_sim(sim_number)
      |> Enum.map(fn(number) ->
        {current_in_number, _} = number |> get_volume_used() |> String.replace(",", "") |> Float.parse()
        {allowance_in_number, _} = number |> get_allowance() |> String.replace(",", "") |> Float.parse()

        %{
          "allowance" => number |> get_allowance(),
          "volume_used_today" => number |> get_volume_used(),
          "percentage_used" => (current_in_number / allowance_in_number * 100) |> Float.round(3),
          "current_in_number" => current_in_number,
          "allowance_in_number" => allowance_in_number,
          "date_of_use" => number |> Map.get(:datetime)
        }
      end) |> Enum.sort(& (&1["percentage_used"] >= &2["percentage_used"]))
    conn
    |> put_status(200)
    |> json(logs)
  end

  def get_sim_logs(conn, _params)  do
    logs = 
      all_sim_numbers()
      |> Enum.map(fn(number) ->
        entries = get_last_two_days(number)

        {current_in_number, _} = entries |> List.first |> get_volume_used() |> String.replace(",", "") |> Float.parse()
        {yesterday_in_number, _} = entries |> List.last |> get_volume_used() |> String.replace(",", "") |> Float.parse()
        {allowance_in_number, _} = entries |> List.first |> get_allowance() |> String.replace(",", "") |> Float.parse()

        %{
          "number" => entries |> List.first |> get_number(),
          "name" => entries |> List.first |> get_name(),
          "allowance" => entries |> List.first |> get_allowance(),
          "volume_used_today" => entries |> List.first |> get_volume_used(),
          "volume_used_yesterday" => entries |> List.last |> get_volume_used(),
          "percentage_used" => get_percentage_used(current_in_number , allowance_in_number),
          "current_in_number" => current_in_number,
          "yesterday_in_number" => yesterday_in_number,
          "allowance_in_number" => allowance_in_number,
          "date_of_use" => entries |> List.first |> Map.get(:datetime)
        }
      end) |> Enum.sort(& (&1["percentage_used"] >= &2["percentage_used"]))
    conn
    |> put_status(200)
    |> json(logs)
  end

  defp get_percentage_used(current_in_number, allowance_in_number) when allowance_in_number > 0  do
    (current_in_number / allowance_in_number * 100) |> Float.round(3)
  end
  defp get_percentage_used(_current_in_number, _allowance_in_number), do: 0

  def create_chartjs_line_data(conn, %{"sim_number" => sim_number } = _params) do
    chartjs_data =
      sim_number
      |> get_all_records_for_sim()
      |> Enum.map(fn(one_record) ->
        {current_in_number, _} = one_record |> get_volume_used() |> String.replace(",", "") |> Float.parse()
        {allowance_in_number, _} = one_record |> get_allowance() |> String.replace(",", "") |> Float.parse()

        %{
          datetime: "#{shift_datetime(one_record.datetime)}",
          percentage_used: (current_in_number / allowance_in_number * 100) |> Float.round(3)
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
    current_user = ensure_user_id(conn, user_id)
    url = "https://rest.nexmo.com/sms/json"
    body = Poison.encode!(%{
      "api_key": System.get_env("NEXMO_API_KEY"),
      "api_secret": System.get_env("NEXMO_API_SECRET"),
      "to": to_number |> number_with_code,
      "from": System.get_env("NEXMO_API_NUMBER"),
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
        status_code |> save_send_sms(results, sms_message, current_user)

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

  defp save_send_sms("0", results, sms_message, user_id) do
    params = %{
      to: results |> Map.get("to") |> number_without_code,
      from: System.get_env("NEXMO_API_NUMBER") |> number_without_code,
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

  defp save_send_sms(_status, _results, _sms_message, _user_id), do: :noop

  def receive_sms(conn, params) do
    params = %{
      to: params["to_number"] |> number_without_code,
      from: params["from_number"] |> number_without_plus_code,
      message_id: params["external_id"],
      status: "Received",
      text: params["content"],
      type: "MO",
      user_id: 0
    }
    changeset = SimMessages.changeset(%SimMessages{}, params)
    case Repo.insert(changeset) do
      {:ok, _} -> Logger.info "SMS has been saved"
      {:error, changeset} -> Logger.info Util.parse_changeset(changeset)
    end
    conn
    |> json(%{void: 0})
  end

  def delivery_receipt(conn, params) do
    get_message(params["messageId"])
    |> ensure_message(params)

    conn
    |> json(%{void: 0})
  end

  def get_single_sim_sms(conn, %{"sim_number" => sim_number} = _params) do
    single_sim_sms =
      get_single_sim_messages(sim_number)
      |> Enum.map(fn(sms) ->
        %{
          inserted_at: sms.inserted_at,
          type: sms.type,
          status: sms.status,
          text: sms.text
        }
      end)
    conn
    |> put_status(200)
    |> json(single_sim_sms)
  end

  defp ensure_user_id(conn, nil), do: conn.assigns[:current_user] |> Map.get(:id)
  defp ensure_user_id(_conn, user_id), do: user_id

  defp ensure_message(nil, _params), do: Logger.info "Message didn't send from EC."
  defp ensure_message(message_id, params) do
    message_id
    |> SimMessages.changeset(%{
      status: params["status"]
    })
    |> Repo.update
    |> case do
      {:ok, _} -> Logger.info "SMS Status has been Updated"
      {:error, changeset} -> Logger.info Util.parse_changeset(changeset)
    end
  end

  defp number_with_code("0" <> number), do: "353#{number}"

  defp number_without_code("353" <> number), do: "0#{number}"

  defp number_without_plus_code("+353" <> number), do: "0#{number}"

  defp shift_datetime(datetime) do
    datetime
    |> Calendar.Strftime.strftime("%Y-%m-%d %H:%M:%S")
    |> elem(1)
  end

  defp get_volume_used(log) do
    log.volume_used
  end

  defp get_name(log) do
    log.name
  end

  defp get_number(log) do
    log.number
  end

  defp get_allowance(log) do
    log.allowance
  end
end