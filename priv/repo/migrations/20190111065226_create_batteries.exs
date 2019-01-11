defmodule EdgeCommander.Repo.Migrations.CreateBatteries do
  use Ecto.Migration

  def change do
	create table(:batteries) do
      add :name, :string
      add :source_url, :string
      add :active, :boolean, default: true, null: false
      add :user_id, references(:users)

      timestamps()
    end
  end
end
