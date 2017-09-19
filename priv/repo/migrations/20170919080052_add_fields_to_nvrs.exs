defmodule EdgeCommander.Repo.Migrations.AddFieldsToNvrs do
  use Ecto.Migration

  def change do
    alter table(:nvrs) do
      add :nvr_status, :boolean, default: true, null: false
    end
  end
end
