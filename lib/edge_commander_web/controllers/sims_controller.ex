defmodule EdgeCommanderWeb.SimsController do
  use EdgeCommanderWeb, :controller
  import EdgeCommander.ThreeScraper, only: [all_sim_numbers: 0, get_last_two_days: 1, get_all_records_for_sim: 1]
  require IEx

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
          percentage_used: "#{(current_in_number / allowance_in_number * 100) |> Float.round(3)} %",
          current_in_number: current_in_number,
          yesterday_in_number: yesterday_in_number,
          allowance_in_number: allowance_in_number,
          date_of_use: entries |> List.first |> Map.get(:datetime)
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
      "logs": logs
    })
  end

  def create_chartjs_line_data(conn, %{"sim_number" => sim_number } = _params) do
    chartjs_data =
      sim_number
      |> get_all_records_for_sim()
      |> Enum.map(fn(one_record) ->
        {current_in_number, _} = one_record |> get_volume_used() |> String.replace(",", "") |> Float.parse()
        {allowance_in_number, _} = one_record |> get_allowance() |> String.replace(",", "") |> Float.parse()

        %{
          datetime: "#{shit_datetime(one_record.datetime)}",
          percentage_used: (current_in_number / allowance_in_number * 100) |> Float.round(3)
        }
      end)

    conn
    |> put_status(200)
    |> json(%{
      "chartjs_data": chartjs_data
    })
  end

  defp shit_datetime(datetime) do
    datetime
    |> Calendar.Strftime.strftime("%A")
    |> IO.inspect
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