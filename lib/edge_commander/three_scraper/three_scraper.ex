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
    # Repo.insert_all(SimLogs, sims)
    Logger.info "Inserting SIMS DATA"
    Process.send_after(self(), :work, @period)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.error([to_string(__MODULE__), " unhandled message", ?\n, inspect(msg)])
    {:noreply, state}
  end

  def all_sim_numbers do
    SimLogs
    |> select([sim], sim.number)
    |> distinct(true)
    |> Repo.all
  end

  def get_last_two_days(number) do
    SimLogs
    |> where(number: ^number)
    |> order_by(desc: :id)
    |> limit(2)
    |> Repo.all
  end

  def list_sim_logs do
    Repo.all(SimLogs)
  end

  def get_sim_logs!(id), do: Repo.get!(SimLogs, id)

  def create_sim_logs(attrs \\ %{}) do
    %SimLogs{}
    |> SimLogs.changeset(attrs)
    |> Repo.insert()
  end

  def update_sim_logs(%SimLogs{} = sim_logs, attrs) do
    sim_logs
    |> SimLogs.changeset(attrs)
    |> Repo.update()
  end

  def delete_sim_logs(%SimLogs{} = sim_logs) do
    Repo.delete(sim_logs)
  end

  def change_sim_logs(%SimLogs{} = sim_logs) do
    SimLogs.changeset(sim_logs, %{})
  end
end
