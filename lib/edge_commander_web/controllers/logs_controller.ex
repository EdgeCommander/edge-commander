defmodule EdgeCommanderWeb.LogsController do
  use EdgeCommanderWeb, :controller
  import Ecto.Query, warn: false
  import EdgeCommander.Activity, only: [get_list_logs: 3]
  alias EdgeCommander.Util

  def get_user_logs(conn, params)  do
    current_user_id = Util.get_user_id(conn, params)
    from_date = params["from_date"]
    to_date = params["to_date"]
    activity_logs = 
      get_list_logs(from_date, to_date, current_user_id)
      |> Enum.map(fn(log) ->
        %{
          id: log.id,
          browser: log.browser,
          platform: log.platform,
          country: log.country,
          country_code: log.country_code,
          event: log.event,
          ip: log.ip,
          inserted_at: log.inserted_at |> Util.shift_zone()
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        activity_logs: activity_logs
      })
  end
end
