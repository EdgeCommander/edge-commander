defmodule EdgeCommanderWeb.SimsController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  alias EdgeCommander.ThreeScraper.SimLogs
  import EdgeCommander.ThreeScraper, only: [all_sim_numbers: 0, get_last_two_days: 1]
  require IEx

  def get_sim_logs(conn, _params)  do
    logs = 
      all_sim_numbers()
      |> Enum.map(fn(number) ->
        entries = get_last_two_days(number)
        %{
          number: entries |> List.first |> get_number(),
          name: entries |> List.first |> get_name(),
          allowance: entries |> List.first |> get_allowance(),
          volume_used_today: entries |> List.first |> get_volume_used(),
          volume_used_yesterday: entries |> List.last |> get_volume_used()
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
      "logs": logs
    })
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