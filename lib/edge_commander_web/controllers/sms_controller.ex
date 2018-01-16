defmodule EdgeCommanderWeb.SmsController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Nexmo.SimMessages
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Nexmo, only: [list_sms_messages: 0]

  def get_all_sms(conn, _params)  do
    sms_messages = 
      list_sms_messages()
      |> Enum.map(fn(sms) ->
        %{
          id: sms.id,
          from: sms.from,
          to: sms.to,
          message_id: sms.message_id,
          status: sms.status,
          text: sms.text,
          type: sms.type,
          inserted_at: sms.inserted_at
        }
      end)
    conn
    |> put_status(200)
    |> json(sms_messages)
  end
end