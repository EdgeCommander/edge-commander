defmodule EdgeCommander.Repo.Migrations.AddMoreFieldsToSimLogs do
  use Ecto.Migration

  def change do
    alter table(:sim_logs) do
      add :sim_provider, :string
    end
  end
end
