defmodule EdgeCommander.Util do
  require Record
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
    timezone_value = Timex.Timezone.get(timezone, Timex.now())
    date_time =
      timestamp
      |> Timex.Timezone.convert(timezone_value)
      |> DateTime.to_naive
  end
end
