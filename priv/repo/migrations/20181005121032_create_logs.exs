defmodule EdgeCommander.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :browser, :string
      add :platform, :string
      add :country, :string
      add :country_code, :string
      add :event, :string
      add :ip, :string
      add :user_id, references(:users)

      timestamps()
    end

  end
end
