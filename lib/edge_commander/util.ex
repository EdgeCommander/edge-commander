defmodule EdgeCommander.Util do
  require Record
  import EdgeCommander.Accounts, only: [current_user: 1, by_api_keys: 2]
  import Plug.Conn
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText,    Record.extract(:xmlText,    from_lib: "xmerl/include/xmerl.hrl")

  def parse_changeset(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn
      {msg, opts} -> String.replace(msg, "%{count}", to_string(opts[:count]))
      msg -> msg
    end)
  end

  def parse_inner_array(text) do
    text
    |> String.to_charlist
    |> :xmerl_scan.string
  end

  def parse_single_element({ xml, _ }, node) do
    case :xmerl_xpath.string(node, xml) do
      [element] ->
        [text] = xmlElement(element, :content)
        xmlText(text, :value) |> to_string
      [] -> ""
    end
  end

  def port_open?(address, port) do
    case :gen_tcp.connect(to_char_list(address), port, [:binary, active: false], 1000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        true
      {:error, _error} ->
        false
    end
  end

  def shift_zone(timestamp, timezone \\ "Europe/Dublin") do
    %{year: year, month: month, day: day, hour: hour, minute: minute, second: second} = timestamp
    Calendar.DateTime.from_erl!({{year, month, day}, {hour, minute, second}}, "UTC")
    |> Calendar.DateTime.shift_zone(timezone)
    |> case do
      {:ok, datetime} -> datetime |> DateTime.to_naive
      {:ambiguous, datetime} -> datetime.possible_date_times |> hd |> DateTime.to_naive
    end
  end

  def get_user_id(conn, params) do
    api_key = params["api_key"]
    api_id = params["api_id"]

    if api_key == nil or api_id == nil do
      current_user = current_user(conn)
      current_user_id = current_user.id
    else
      users = by_api_keys(api_id, api_key)
      current_user_id = users.id
    end
  end
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("")

  def string_generator(length) do
    Enum.reduce((1..length), [], fn (_i, acc) ->
      [Enum.random(@chars) | acc]
    end) |> Enum.join("")
  end

  def user_request_ip(conn) do
    ip = case get_req_header(conn, "x-forwarded-for") do
       [proxy_ip] -> proxy_ip |> first_ip |> valid_ip
       _ -> conn.remote_ip |> Tuple.to_list |> Enum.join(".") |> valid_ip
    end
    ip
  end

  defp first_ip(ips) do
    case String.split(ips, ",") do
      [ip] -> ip
      [ip, _proxy_ip] -> ip
    end
  end

  defp valid_ip(ip) do
    re = ~r/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
    case Regex.match?(re, ip) do
      true -> ip
      false -> nil
    end
  end
end
