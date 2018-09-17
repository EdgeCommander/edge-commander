defmodule EdgeCommanderWeb.SmsController do
  use EdgeCommanderWeb, :controller
  import Ecto.Query, warn: false
  import EdgeCommander.Nexmo, only: [list_sms_messages: 3]
  import EdgeCommander.Accounts, only: [current_user: 1]
  import EdgeCommander.ThreeScraper, only: [get_last_record_for_number: 1]
  alias EdgeCommander.Util

  def get_all_sms(conn, params)  do
    current_user_id = Util.get_user_id(conn, params)
    from_date = params["from_date"]
    to_date = params["to_date"]
    sms_messages = 
      list_sms_messages(from_date, to_date, current_user_id)
      |> Enum.map(fn(sms) ->
        %{
          id: sms.id,
          from: sms.from,
          from_name: sms.from |> get_name,
          to: sms.to,
          to_name: sms.to |> get_name,
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

  defp get_name(number) do
    ir_nexmo_number = "+" <> System.get_env("NEXMO_API_IR_NUMBER")
    uk_nexmo_number = "+" <> System.get_env("NEXMO_API_UK_NUMBER")
    if number == ir_nexmo_number or  number == uk_nexmo_number do
      name = "EdgeCommander"
    else
     record =  get_last_record_for_number(number)
     name = record.name
    end
    name
  end
end