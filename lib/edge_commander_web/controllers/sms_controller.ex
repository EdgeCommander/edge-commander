defmodule EdgeCommanderWeb.SmsController do
  use EdgeCommanderWeb, :controller
  import Ecto.Query, warn: false
  import EdgeCommander.Nexmo, only: [list_sms_messages: 3]
  import EdgeCommander.Accounts, only: [current_user: 1]
  alias EdgeCommander.Util

  def get_all_sms(conn, params)  do
    current_user = current_user(conn)
    current_user_id = current_user.id
    from_date = params["from_date"]
    to_date = params["to_date"]
    sms_messages = 
      list_sms_messages(from_date, to_date, current_user_id)
      |> Enum.map(fn(sms) ->
        %{
          id: sms.id,
          from: sms.from,
          to: sms.to,
          message_id: sms.message_id,
          status: sms.status,
          text: sms.text,
          type: sms.type,
          inserted_at: sms.inserted_at |> Util.shift_zone()
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        "sms_messages": sms_messages
      })
  end
end