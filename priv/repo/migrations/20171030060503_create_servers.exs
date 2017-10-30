defmodule EdgeCommander.Repo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    create table(:servers) do
      add :ip, :string
      add :username, :string
      add :password, :string

      timestamps()
    end

  end
end
