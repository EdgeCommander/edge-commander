defmodule EdgeCommander.Portable do
  @moduledoc """
  The Monitors context.
  """
  require Logger
  import EdgeCommander.Monitors
  import EdgeCommander.Devices
  import Ecto.Query, warn: false
  alias EdgeCommander.Repo
  alias EdgeCommander.Devices.Nvr
  alias EdgeCommander.Monitors.NvrPorts

  def start_porting do
    get_monitored_nvrs()
    |> Enum.each(fn(nvr) ->
      :gen_tcp.connect(to_charlist(nvr.nvr_ip), nvr.nvr_port, [:binary, active: false], 1000)
      |> port_status_to_db(nvr)
    end)
  end

  def port_status_to_db({:ok, _}, nvr) do
    changeset_to_db(nvr, true)
    update_nvr_status(nvr, true)
  end
  def port_status_to_db({:error, _}, nvr) do
    changeset_to_db(nvr, false)
    update_nvr_status(nvr, false)
  end
  # {:error, :nxdomain}
  # {:error, :timeout}

  def update_nvr_status(nvr, status) do
    IO.inspect status
    get_nvr!(nvr.nvr_id)
    |> Nvr.changeset(%{nvr_status: status})
    |> Repo.update!()
  end

  def changeset_to_db(nvr, status) do
    %NvrPorts{}
    |> NvrPorts.changeset(%{
        nvr_id: nvr.nvr_id,
        nvr_name: nvr.nvr_name,
        status: status,
        done_at: Calendar.DateTime.now_utc,
        nvr_created_at: nvr.nvr_created_at,
        nvr_user_id: nvr.nvr_user_id
    })
    |> Repo.insert()
    |> rest_the_case
  end

  defp rest_the_case({:ok, _}), do: Logger.info "Log added."
  defp rest_the_case({:error, changeset}), do: Logger.info "Error: #{changeset}"
end

