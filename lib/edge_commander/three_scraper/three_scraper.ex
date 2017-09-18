defmodule EdgeCommander.ThreeScraper do
  @moduledoc """
  The ThreeScraper context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.ThreeScraper.SimLogs

  use GenServer
  require Logger
  alias ThreeScraper.SIM

  @period 12 * 60 * 60 * 1000 # 24 hour

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end


  def init(_args) do
    Process.send_after(self(), :work, 10 * 1000) # ten seconds
    {:ok, nil}
  end

  def handle_info(:work, state) do
    Logger.info "Getting SIMS DATA"
    sims = SIM.get_info() |> Enum.map(&Map.from_struct/1)
    Repo.insert_all(SimLogs, sims)
    Logger.info "Inserting SIMS DATA"
    Process.send_after(self(), :work, @period)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.error([to_string(__MODULE__), " unhandled message", ?\n, inspect(msg)])
    {:noreply, state}
  end

  @doc """
  Returns the list of sim_logs.

  ## Examples

      iex> list_sim_logs()
      [%SimLogs{}, ...]

  """
  def list_sim_logs do
    Repo.all(SimLogs)
  end

  @doc """
  Gets a single sim_logs.

  Raises `Ecto.NoResultsError` if the Sim logs does not exist.

  ## Examples

      iex> get_sim_logs!(123)
      %SimLogs{}

      iex> get_sim_logs!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sim_logs!(id), do: Repo.get!(SimLogs, id)

  @doc """
  Creates a sim_logs.

  ## Examples

      iex> create_sim_logs(%{field: value})
      {:ok, %SimLogs{}}

      iex> create_sim_logs(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sim_logs(attrs \\ %{}) do
    %SimLogs{}
    |> SimLogs.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sim_logs.

  ## Examples

      iex> update_sim_logs(sim_logs, %{field: new_value})
      {:ok, %SimLogs{}}

      iex> update_sim_logs(sim_logs, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sim_logs(%SimLogs{} = sim_logs, attrs) do
    sim_logs
    |> SimLogs.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SimLogs.

  ## Examples

      iex> delete_sim_logs(sim_logs)
      {:ok, %SimLogs{}}

      iex> delete_sim_logs(sim_logs)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sim_logs(%SimLogs{} = sim_logs) do
    Repo.delete(sim_logs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sim_logs changes.

  ## Examples

      iex> change_sim_logs(sim_logs)
      %Ecto.Changeset{source: %SimLogs{}}

  """
  def change_sim_logs(%SimLogs{} = sim_logs) do
    SimLogs.changeset(sim_logs, %{})
  end
end
