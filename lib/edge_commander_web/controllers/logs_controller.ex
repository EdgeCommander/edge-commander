defmodule EdgeCommanderWeb.LogsController do
  use EdgeCommanderWeb, :controller
  import Ecto.Query, warn: false
  alias EdgeCommander.Util
  alias EdgeCommander.Repo

  def get_user_logs(conn, params)  do
    from_date = if params["fromDate"] == nil, do: Util.get_required_day_date(-7), else: params["fromDate"]
    to_date = if params["toDate"] == nil, do: Util.get_current_date_only, else: params["toDate"]

    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = "select * from logs as lg Where (DATE(inserted_at) >= '#{from_date}' and DATE(inserted_at) <= '#{to_date}') and  (lower(lg.country) like lower('%#{search}%') or lower(lg.browser) like lower('%#{search}%'))  #{add_sorting(column, order)}"
    logs = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map logs.columns, &(String.to_atom(&1))
    roles = Enum.map logs.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = logs.num_rows
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
            log = Enum.at(roles, i)
            lg = %{
              id: log[:id],
              browser: log[:browser],
              platform: log[:platform],
              country: log[:country],
              country_code: log[:country_code],
              event: log[:event],
              ip: log[:ip],
              inserted_at: log[:inserted_at] |> Util.shift_zone()
            }
            acc ++ [lg]
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
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/user_logs?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/user_logs?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("browser", order), do: "ORDER BY browser #{order}"
  defp add_sorting("platform", order), do: "ORDER BY platform #{order}"
  defp add_sorting("country", order), do: "ORDER BY country #{order}"
  defp add_sorting("country_code", order), do: "ORDER BY country_code #{order}"
  defp add_sorting("event", order), do: "ORDER BY event #{order}"
  defp add_sorting("ip", order), do: "ORDER BY ip #{order}"
  defp add_sorting("inserted_at", order), do: "ORDER BY inserted_at #{order}"

end
