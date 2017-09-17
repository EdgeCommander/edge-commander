defmodule EdgeCommander.Repo.Migrations.CreateSimLogs do
  use Ecto.Migration

  def change do
    create table(:sim_logs) do
      add :number, :string
      add :name, :string
      add :addon, :string
      add :allowance, :string
      add :volume_used, :string
      add :datatime, :naive_datetime

      timestamps()
    end

  end
end
