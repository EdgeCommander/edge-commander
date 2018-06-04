defmodule EdgeCommander.Repo.Migrations.AddUserIdFieldToSimLogs do
  use Ecto.Migration

  def change do
    alter table(:sim_logs) do
      add :user_id, references(:users)
    end
  end
end
