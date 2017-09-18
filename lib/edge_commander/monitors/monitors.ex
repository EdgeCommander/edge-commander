defmodule EdgeCommander.Monitors do
  @moduledoc """
  The Monitors context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Monitors.NvrPorts

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
