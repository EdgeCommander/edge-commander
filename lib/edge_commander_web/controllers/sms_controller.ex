defmodule EdgeCommanderWeb.SmsController do
  use EdgeCommanderWeb, :controller
  import Ecto.Query, warn: false
  import EdgeCommander.Nexmo, only: [list_sms_messages: 3]
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
          inserted_at: sms.inserted_at |> Util.shift_zone(),
          delivery_datetime: sms.delivery_datetime |> validate_dateTime
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        sms_messages: sms_messages
      })
  end

  defp get_name(number) do
    ir_nexmo_number = "+" <> System.get_env("NEXMO_API_IR_NUMBER")
    uk_nexmo_number = "+" <> System.get_env("NEXMO_API_UK_NUMBER")
    if number == ir_nexmo_number or  number == uk_nexmo_number do
      "EdgeCommander"
    else
     get_last_record_for_number(number) |> validate_sim_name
    end
  end

  defp validate_sim_name(nil), do: "---"
  defp validate_sim_name(record), do: record.name

  defp validate_dateTime(nil),  do: ""
  defp validate_dateTime(delivery_datetime),  do: delivery_datetime |> Util.shift_zone()
end
