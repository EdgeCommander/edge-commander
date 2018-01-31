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

  defp get_current_status(nvr_id) do
    ConCache.get(:current_nvr_status, nvr_id)
  end

  def port_status_to_db({:ok, _}, nvr) do
    case get_current_status(nvr.nvr_id) do
      nil ->
        changeset_to_db(nvr, true)
        update_nvr_status(nvr, nil, true)
      false ->
        changeset_to_db(nvr, true)
        update_nvr_status(nvr, nil, true)
      true ->
        Logger.info "Status already true."
    end
  end
  def port_status_to_db({:error, reason}, nvr) do
    case get_current_status(nvr.nvr_id) do
      nil ->
        changeset_to_db(nvr, false)
        update_nvr_status(nvr, reason, false)
      true ->
        changeset_to_db(nvr, false)
        update_nvr_status(nvr, reason, false)
      false ->
        Logger.info "Status already false."
    end
  end
  # {:error, :nxdomain}
  # {:error, :timeout}

  def update_nvr_status(nvr, nil, status) do
    get_nvr!(nvr.nvr_id)
    |> Nvr.changeset(%{nvr_status: status})
    |> Repo.update!()
  end

  def update_nvr_status(nvr, reason, status) do
    reason_value =
      reason
      |> Kernel.inspect()
      |> String.replace(":", "")

    nvr_record = get_nvr!(nvr.nvr_id)
    nvr_record.extra
    |> ensure_extra_data(nvr_record, reason_value, status)
  end

  def changeset_to_db(nvr, status) do
    ConCache.dirty_put(:current_nvr_status, nvr.nvr_id, status)
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

  defp ensure_extra_data(nil, _nvr_record, _reason_value, _status), do: :noop
  defp ensure_extra_data(nvr_record_extra, nvr_record, reason_value, status) do
    extra =
      nvr_record_extra
      |> Map.delete("reason")
      |> Map.put("reason", reason_value)

    nvr_record
    |> Nvr.changeset(%{nvr_status: status, extra: extra})
    |> Repo.update!()
  end
end

