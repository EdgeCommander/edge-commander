defmodule EdgeCommanderWeb.SimsController do
  use EdgeCommanderWeb, :controller
  import EdgeCommander.ThreeScraper, only: [all_sim_numbers: 0, get_last_two_days: 1, get_all_records_for_sim: 1, get_single_sim: 1]
  require IEx

  def get_single_sim_data(conn, %{"sim_number" => sim_number } = _params) do
    logs =
      get_single_sim(sim_number)
      |> Enum.map(fn(number) ->
        {current_in_number, _} = number |> get_volume_used() |> String.replace(",", "") |> Float.parse()
        {allowance_in_number, _} = number |> get_allowance() |> String.replace(",", "") |> Float.parse()

        %{
          allowance: number |> get_allowance(),
          volume_used_today: number |> get_volume_used(),
          percentage_used: "#{(current_in_number / allowance_in_number * 100) |> Float.round(3)} %",
          current_in_number: current_in_number,
          allowance_in_number: allowance_in_number,
          date_of_use: number |> Map.get(:datetime)
        }
      end)
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
          number: entries |> List.first |> get_number(),
          name: entries |> List.first |> get_name(),
          allowance: entries |> List.first |> get_allowance(),
          volume_used_today: entries |> List.first |> get_volume_used(),
          volume_used_yesterday: entries |> List.last |> get_volume_used(),
          percentage_used: (current_in_number / allowance_in_number * 100) |> Float.round(3),
          current_in_number: current_in_number,
          yesterday_in_number: yesterday_in_number,
          allowance_in_number: allowance_in_number,
          date_of_use: entries |> List.first |> Map.get(:datetime)
        }
      end)
    conn
    |> put_status(200)
    |> json(logs)
  end

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

  def send_sms(conn,  %{"sms_message" => sms_message, "to_number" => to_number} = _params)  do
    url = "https://rest.nexmo.com/sms/json"
    body = Poison.encode!(%{
      "api_key": System.get_env("NEXMO_API_KEY"),
      "api_secret": System.get_env("NEXMO_API_SECRET"),
      "to": to_number |> number_with_code,
      "from": "EdgeCommander" ,
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

  defp number_with_code("0" <> number), do: "+353#{number}"

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