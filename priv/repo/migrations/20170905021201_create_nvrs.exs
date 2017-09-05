defmodule EdgeCommander.Repo.Migrations.CreateNvrs do
  use Ecto.Migration

  def change do
    create table(:nvrs) do
      add :name, :string
      add :ip, :string
      add :port, :string
      add :username, :string
      add :password, :string
      add :is_monitoring, :boolean, default: false, null: false
      add :model, :string
      add :firmware_version, :string
      add :extra, :map

      timestamps()
    end

  end
end
