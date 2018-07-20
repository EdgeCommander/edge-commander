defmodule EdgeCommander.Monitors do
  @moduledoc """
  The Monitors context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Monitors.NvrPorts
  alias EdgeCommander.Devices.Nvr

  def get_logs_for_days(days, current_user_id) do
    {day, ""} = days |> Integer.parse
    days_in_seconds = day * 24 * 60 * 60
    utc_now =
      Calendar.DateTime.now_utc
      |> Calendar.DateTime.to_erl
      |> Calendar.DateTime.from_erl!("Etc/UTC", {123456, 6})

    from_date =
      utc_now
      |> Calendar.DateTime.advance!(days_in_seconds)

    current_user_nvrs =
      Nvr
      |> where(user_id: ^current_user_id)
      |> Repo.all
      |> Enum.map(fn(nvr) -> nvr.id end)

    NvrPorts
    |> where([nvr], nvr.nvr_id in ^current_user_nvrs)
    |> where([nvr], nvr.done_at >= ^from_date and nvr.done_at <= ^utc_now)
    |> order_by([nvr], asc: nvr.done_at)
    |> Repo.all
  end

  def get_monitored_nvrs do
    Nvr
    |> select([nvr], %{nvr_id: nvr.id, nvr_ip: nvr.ip, nvr_port: nvr.port, nvr_name: nvr.name, nvr_created_at: nvr.inserted_at, nvr_user_id: nvr.user_id})
    |> where([nvr], nvr.is_monitoring == true)
    |> distinct([nvr], nvr.ip)
    |> Repo.all
  end

  def list_nvr_ports do
    Repo.all(NvrPorts)
  end

  def get_nvr_ports!(id), do: Repo.get!(NvrPorts, id)

  def create_nvr_ports(attrs \\ %{}) do
    %NvrPorts{}
    |> NvrPorts.changeset(attrs)
    |> Repo.insert()
  end

  def update_nvr_ports(%NvrPorts{} = nvr_ports, attrs) do
    nvr_ports
    |> NvrPorts.changeset(attrs)
    |> Repo.update()
  end

  def delete_nvr_ports(%NvrPorts{} = nvr_ports) do
    Repo.delete(nvr_ports)
  end

  def change_nvr_ports(%NvrPorts{} = nvr_ports) do
    NvrPorts.changeset(nvr_ports, %{})
  end
end
