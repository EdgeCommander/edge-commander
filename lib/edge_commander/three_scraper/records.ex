defmodule EdgeCommander.ThreeScraper.Records do
  @moduledoc """
  The ThreeScraper context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.ThreeScraper.SimLogs
  alias EdgeCommander.ThreeScraper.Sims
  alias EdgeCommander.ThreeScraper.ThreeUsers
  require Logger

  def all_sim_numbers do
    SimLogs
    |> select([sim], sim.number)
    |> distinct(true)
    |> Repo.all
  end

  def get_sim_bill_day(number) do
    query = from l in SimLogs,
      left_join: t in ThreeUsers, on: l.three_user_id == t.id,
      where: (l.number == ^number),
      select: %{bill_day: t.bill_day},
      distinct: [l.number],
      order_by: [desc: l.id]
    query
    |>  Repo.one
  end

  def get_last_record_for_number(number) do
    SimLogs
    |> where(number: ^number)
    |> order_by(desc: :id)
    |> limit(1)
    |> Repo.one
  end

  def last_record_for_number_by_user(number) do
    SimLogs
    |> where([c], c.number == ^number)
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

  def get_single_sim_by_user(sim_number) do
    query = from l in SimLogs,
      where: l.number == ^sim_number
    query
    |> distinct([s], [desc: fragment("date_trunc('day', ?)", s.datetime)])
    |> order_by(desc: :id)
    |>  Repo.all
  end

  def get_all_records_for_sim(sim_number) do
    SimLogs
    |> where(number: ^sim_number)
    |> distinct([s], fragment("date_trunc('day', ?)", s.datetime))
    |> order_by(asc: :datetime)
    |> Repo.all
  end

  def get_all_records_for_sim_by_user(sim_number) do
    query = from l in SimLogs,
      where: l.number == ^sim_number
    query
    |> distinct([s], fragment("date_trunc('day', ?)", s.datetime))
    |> order_by(asc: :datetime)
    |>  Repo.all
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

  def get_yesterday_usage(number) do
    query = from l in SimLogs,
      where: l.number == ^number,
      select: %{yesterday_volume_used: l.volume_used},
      order_by: [desc: l.id],
      limit: 1,
      offset: 1
    query
    |> Repo.one
  end

  ##=======================================sims=======================================

  def numbers_by_three_user_id(three_user_id) do
    Sims
    |> where(three_user_id: ^three_user_id)
    |> Repo.all
  end

  def get_all_users_by_number(sim_number) do
    Sims
    |> select([sim], sim.user_id)
    |> where(number: ^sim_number)
    |> Repo.all
  end

  def get_single_sim(number) do
    Sims
    |> where(number: ^number)
    |> Repo.one
  end

  def get_last_bill_date(number) do
    Sims
    |> select([sim], sim.last_bill_date)
    |> where(number: ^number)
    |> Repo.one
  end

  def get_sim!(id), do: Repo.get!(Sims, id)

  def get_sims() do
    Sims
    |> Repo.all
  end
end
