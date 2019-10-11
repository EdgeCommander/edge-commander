defmodule EdgeCommanderWeb.SmsController do
  use EdgeCommanderWeb, :controller
  import Ecto.Query, warn: false
  import EdgeCommander.Nexmo, only: [get_all_messages: 2]
  import EdgeCommander.ThreeScraper.Records, only: [get_single_sim: 1]
  alias EdgeCommander.Util
  alias EdgeCommander.Repo

  def get_all_sms(conn, params)  do

    from_date = if params["fromDate"] == nil, do: Util.get_required_day_date(-7), else: params["fromDate"]
    to_date = if params["toDate"] == nil, do: Util.get_current_date_only, else: params["toDate"]

    params = Map.put(params, "fromDate", from_date)
    params = Map.put(params, "toDate", to_date)
    conditions = condition(params)

    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = "select * from sms_messages_view as ms Where (DATE(inserted_at) >= '#{from_date}' and DATE(inserted_at) <= '#{to_date}') #{conditions} #{add_sorting(column, order)}"
    messages = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map messages.columns, &(String.to_atom(&1))
    roles = Enum.map messages.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = messages.num_rows
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
            messages = Enum.at(roles, i)
            ms = %{
              id: messages[:id],
              from: messages[:from],
              from_name: messages[:from] |> get_name,
              to: messages[:to],
              to_name: messages[:to] |> get_name,
              message_id: messages[:message_id],
              status: messages[:status],
              text: messages[:text],
              type: messages[:type],
              inserted_at: messages[:inserted_at] |> Util.shift_zone(),
              delivery_datetime: messages[:delivery_datetime] |> validate_dateTime
            }
            acc ++ [ms]
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
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/get_all_sms?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/get_all_sms?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  defp condition(params) do
    Enum.reduce(params, "", fn param, condition = _acc ->
      {name, value} = param
      cond do
        name == "text" && value != "" -> " and (lower(ms.text) like lower('%#{value}%'))"
        name == "sim_name" && value != "" -> " and ((lower(ms.from_name) like lower('%#{value}%')) or (lower(ms.to_name ) like lower('%#{value}%')))"
        name == "type" && value != "" -> " and (lower(ms.type) like lower('%#{value}%'))"
        name == "status" && value != "" -> " and (lower(ms.status) like lower('%#{value}%'))"
        name == "number" && value != "" -> " and ((lower(ms.from) like lower('%#{value}%')) or (lower(ms.to) like lower('%#{value}%')))"
        name == "message_delivery" && value != "" -> " and (lower(ms.delivery_datetime) like lower('%#{change_datetime_format(value)}%'))"
        true -> condition
      end
    end)
  end

  defp change_datetime_format(""), do: ""
  defp change_datetime_format(value) do
    [date, time] = String.split(value, " ")
    [day, month, year] = String.split(date, "-")
    "#{year}-#{month}-#{day} #{time}"
  end

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("from", order), do: "ORDER BY [from] #{order}"
  defp add_sorting("to", order), do: "ORDER BY to #{order}"
  defp add_sorting("message_id", order), do: "ORDER BY message_id #{order}"
  defp add_sorting("status", order), do: "ORDER BY status #{order}"
  defp add_sorting("text", order), do: "ORDER BY text #{order}"
  defp add_sorting("type", order), do: "ORDER BY type #{order}"
  defp add_sorting("inserted_at", order), do: "ORDER BY inserted_at #{order}"
  defp add_sorting("delivery_datetime", order), do: "ORDER BY delivery_datetime #{order}"

  defp get_name(number) do
    ir_nexmo_number = "+#{System.get_env("NEXMO_API_IR_NUMBER")}"
    uk_nexmo_number = "+#{System.get_env("NEXMO_API_UK_NUMBER")}"

    if number == ir_nexmo_number or  number == uk_nexmo_number do
      "EdgeCommander"
    else
     get_single_sim(number) |> validate_sim_name
    end
  end

  defp validate_sim_name(nil), do: "---"
  defp validate_sim_name(record), do: record.name

  defp validate_dateTime(nil),  do: ""
  defp validate_dateTime(delivery_datetime),  do: delivery_datetime
end
