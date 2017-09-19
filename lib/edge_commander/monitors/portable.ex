defmodule EdgeCommander.Portable do
  @moduledoc """
  The Monitors context.
  """
  require Logger
  import EdgeCommander.Monitors
  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Monitors.NvrPorts

  def start_porting do
    get_monitored_nvrs()
    |> Enum.each(fn(nvr) ->
      :gen_tcp.connect(to_charlist(nvr.nvr_ip), nvr.nvr_port, [:binary, active: false], 1000)
      |> port_status_to_db(nvr)
    end)
  end

  def port_status_to_db({:ok, _}, nvr), do: changeset_to_db(nvr, true)
  def port_status_to_db({:error, _}, nvr), do: changeset_to_db(nvr, false)
  # {:error, :nxdomain}
  # {:error, :timeout}

  def changeset_to_db(nvr, status) do
    %NvrPorts{}
    |> NvrPorts.changeset(%{
        nvr_id: nvr.nvr_id,
        nvr_name: nvr.nvr_name,
        status: status,
        done_at: Calendar.DateTime.now_utc
    })
    |> Repo.insert()
    |> rest_the_case
  end

  defp rest_the_case({:ok, _}), do: Logger.info "Log added."
  defp rest_the_case({:error, changeset}), do: Logger.info "Error: #{changeset}"
end

