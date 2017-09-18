defmodule EdgeCommander.Monitors do
  @moduledoc """
  The Monitors context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Monitors.NvrPorts

  @doc """
  Returns the list of nvr_ports.

  ## Examples

      iex> list_nvr_ports()
      [%NvrPorts{}, ...]

  """
  def list_nvr_ports do
    Repo.all(NvrPorts)
  end

  @doc """
  Gets a single nvr_ports.

  Raises `Ecto.NoResultsError` if the Nvr ports does not exist.

  ## Examples

      iex> get_nvr_ports!(123)
      %NvrPorts{}

      iex> get_nvr_ports!(456)
      ** (Ecto.NoResultsError)

  """
  def get_nvr_ports!(id), do: Repo.get!(NvrPorts, id)

  @doc """
  Creates a nvr_ports.

  ## Examples

      iex> create_nvr_ports(%{field: value})
      {:ok, %NvrPorts{}}

      iex> create_nvr_ports(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_nvr_ports(attrs \\ %{}) do
    %NvrPorts{}
    |> NvrPorts.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a nvr_ports.

  ## Examples

      iex> update_nvr_ports(nvr_ports, %{field: new_value})
      {:ok, %NvrPorts{}}

      iex> update_nvr_ports(nvr_ports, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_nvr_ports(%NvrPorts{} = nvr_ports, attrs) do
    nvr_ports
    |> NvrPorts.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a NvrPorts.

  ## Examples

      iex> delete_nvr_ports(nvr_ports)
      {:ok, %NvrPorts{}}

      iex> delete_nvr_ports(nvr_ports)
      {:error, %Ecto.Changeset{}}

  """
  def delete_nvr_ports(%NvrPorts{} = nvr_ports) do
    Repo.delete(nvr_ports)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking nvr_ports changes.

  ## Examples

      iex> change_nvr_ports(nvr_ports)
      %Ecto.Changeset{source: %NvrPorts{}}

  """
  def change_nvr_ports(%NvrPorts{} = nvr_ports) do
    NvrPorts.changeset(nvr_ports, %{})
  end
end
