defmodule EdgeCommander.ThreeScraper do
  @moduledoc """
  The ThreeScraper context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.ThreeScraper.SimLogs
  alias EdgeCommander.Sharing.Member

  use GenServer
  require Logger
  alias ThreeScraper.SIM
  require IEx

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

      new_addon = addon |> ensure_addon_value
      new_allowance = allowance  |> ensure_allowance_value
      new_volume_used = volume_used  |> ensure_used_value
      new_record_list = [new_addon, new_allowance, new_volume_used, name]

      old_data = number |> number_with_code |> get_last_record_for_number()

      old_record_list = old_data |> ensure_old_record

      if (old_record_list == new_record_list) == false do
        sims_logs = %{
          number: number |> number_with_code,
          name: name,
          addon: new_addon,
          allowance: new_allowance |> Float.to_string ,
          volume_used: new_volume_used  |> Float.to_string,
          datetime: datetime,
          sim_provider: "Three Ireland"
        }

      changeset = SimLogs.changeset(%SimLogs{}, sims_logs)
      case Repo.insert(changeset) do
       {:ok, _logs} ->
          Logger.info "Inserting SIM data for #{number}"
        {:error, changeset} ->
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

  def all_sims(user_id) do
    query = from s in SimLogs,
      left_join: m in Member, on: s.user_id == m.user_id,
      where: (m.member_id == ^user_id or s.user_id == ^user_id)
    query
    |> distinct([s], desc: s.name)
    |>  Repo.all
  end

  def all_sim_numbers do
    SimLogs
    |> select([sim], sim.number)
    |> distinct(true)
    |> Repo.all
  end

  def get_sim_numbers(user_id) do
  query = from l in SimLogs, left_join: m in Member, on: l.user_id == m.account_id,
    where: (m.member_id == ^user_id or l.user_id == ^user_id),
    select: %{number: l.number, name: l.name, allowance: l.allowance,  today_volume_used: l.volume_used , yesterday_volume_used: (fragment("(select volume_used from sim_logs where number = ? order by id desc limit 1 OFFSET 1)", l.number)), datetime: l.datetime, sim_provider: l.sim_provider, three_user_id: l.three_user_id, last_sms: (fragment("(select text from sms_messages as s where  s.from = ? or s.to = ? order by id desc limit 1)", l.number, l.number)), last_sms_date: (fragment("(select inserted_at from sms_messages as s where  s.from = ? or s.to = ? order by id desc limit 1)", l.number, l.number))  },
    order_by: [desc: l.id],
    distinct: l.number

    query
    |>  Repo.all
  end

  def get_last_record_for_number(number) do
    SimLogs
    |> where(number: ^number)
    |> order_by(desc: :id)
    |> limit(1)
    |> Repo.one
  end

  def last_record_for_number_by_user(number, user_id) do
    SimLogs
    |> where([c], c.number == ^number and c.user_id == ^user_id)
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

  def get_single_sim_by_user(sim_number, user_id) do
    query = from l in SimLogs,
      left_join: m in Member, on: l.user_id == m.user_id,
      where: (m.member_id == ^user_id or l.user_id == ^user_id) and l.number == ^sim_number
    query
    |> distinct([s], [desc: fragment("date_trunc('day', ?)", s.datetime)])
    |> order_by(desc: :id)
    |>  Repo.all
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

  def get_all_records_for_sim_by_user(sim_number, user_id) do
    query = from l in SimLogs,
      left_join: m in Member, on: l.user_id == m.user_id,
      where: (m.member_id == ^user_id or l.user_id == ^user_id) and l.number == ^sim_number
    query
    |> distinct([s], fragment("date_trunc('day', ?)", s.datetime))
    |> order_by(asc: :datetime)
    |>  Repo.all
  end

  def get_all_users_by_number(sim_number) do
    SimLogs
    |> select([sim], sim.user_id)
    |> where(number: ^sim_number)
    |> distinct(true)
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

  defp number_with_code("0" <> number), do: "+353#{number}"

  defp ensure_allowance_value(-1), do: -1.0
  defp ensure_allowance_value(allowance) do
    {new_allowance, _} = allowance  |> String.replace(",", "") |> Float.parse()
     new_allowance
  end

  defp ensure_used_value("-"), do: 0.0
  defp ensure_used_value(volume_used) do
    {new_volume_used, _} = volume_used  |> String.replace(",", "") |> Float.parse()
    new_volume_used
  end

  defp ensure_addon_value(addon) do
    if is_binary(addon) == true  do
        new_addon = addon
      else
        {new_addon, _} = addon |> String.replace(",", "") |> Float.parse()
    end
    new_addon
  end

  defp ensure_old_record(nil), do: [nil, nil, nil]
  defp ensure_old_record(old_data) do
    old_addon = old_data.addon  |> ensure_addon_value
    old_allowance = old_data.allowance  |> ensure_allowance_value
    old_volume_used = old_data.volume_used  |> ensure_used_value
    old_name = old_data.name
    [old_addon, old_allowance, old_volume_used, old_name]
  end
end
