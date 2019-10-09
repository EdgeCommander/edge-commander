defmodule EdgeCommander.Repo.Migrations.ChangeFieldTypeInLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      modify :event, :text
    end
  end
end
