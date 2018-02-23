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

  @period 6 * 60 * 60 * 1000 # 6 hour

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end


  def init(_args) do
    Process.send_after(self(), :work, 10 * 1000) # ten seconds
    {:ok, nil}
  end

  def handle_info(:work, state) do
    Logger.info "Getting SIMS DATA"
    sim_data =
      SIM.get_info()
      |> Enum.map(&Map.from_struct/1)
      |> Enum.filter(fn(s_sim) -> s_sim.addon != "NIL" end)

    Enum.each(sim_data, fn(log) ->
      addon = log.addon
      allowance = log.allowance
      name = log.name
      number = log.number
      datetime = log.datetime
      volume_used = log.volume_used

      {new_addon, _} = addon |> String.replace(",", "") |> Float.parse()
      {new_allowance, _} = allowance  |> String.replace(",", "") |> Float.parse()
      {new_volume_used, _} = volume_used  |> String.replace(",", "") |> Float.parse()
      new_record_list = [new_addon, new_allowance, new_volume_used]

      old_data = number |> get_last_record_for_number()
      {old_addon, _} = old_data.addon  |> String.replace(",", "") |> Float.parse()
      {old_allowance, _} = old_data.allowance  |> String.replace(",", "") |> Float.parse()
      {old_volume_used, _} = old_data.volume_used  |> String.replace(",", "") |> Float.parse()
      old_record_list = [old_addon, old_allowance, old_volume_used]

      if (old_record_list == new_record_list) == false do
        sims_logs = %{
          number: number,
          name: name,
          addon: addon,
          allowance: allowance,
          volume_used: volume_used,
          datetime: datetime,
          sim_provider: "Three Ireland"
        }
        changeset = SimLogs.changeset(%SimLogs{}, sims_logs)
        case Repo.insert(changeset) do
        {:ok, _logs} ->
          Logger.info "Inserting SIM data for #{number}"
        {:error, _changeset} ->
          Logger.error "Inserting SIM data failed for #{number}"
        end
      else
        Logger.info "Data matched for #{number}"
      end
    end)
    # EdgeCommander.Commands.start_usage_command
    Process.send_after(self(), :work, @period)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.error([to_string(__MODULE__), " unhandled message", ?\n, inspect(msg)])
    {:noreply, state}
  end

  def all_sims do
    SimLogs
    |> distinct([s], desc: s.name)
    |> Repo.all
  end

  def all_sim_numbers do
    SimLogs
    |> select([sim], sim.number)
    |> distinct(true)
    |> Repo.all
  end

  def get_last_record_for_number(number) do
    SimLogs
    |> where(number: ^number)
    |> order_by(desc: :id)
    |> limit(1)
    |> Repo.one
  end

  def get_last_two_days(number) do
    SimLogs
    |> where(number: ^number)
    |> distinct([s], [desc: fragment("date_trunc('day', ?)", s.datetime)])
    |> order_by(desc: :id)
    |> limit(2)
    |> Repo.all
  end

  def get_single_sim(sim_number) do
    SimLogs
    |> where(number: ^sim_number)
    |> distinct([s], [desc: fragment("date_trunc('day', ?)", s.datetime)])
    |> order_by(desc: :id)
    |> Repo.all
  end

  def get_sim_name(sim_number) do
    SimLogs
    |> where(number: ^sim_number)
    |> order_by(desc: :id)
    |> limit(1)
    |> Repo.one
    |> Map.get(:name)
  end

  def get_all_records_for_sim(sim_number) do
    SimLogs
    |> where(number: ^sim_number)
    |> distinct([s], fragment("date_trunc('day', ?)", s.datetime))
    |> order_by(asc: :datetime)
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
