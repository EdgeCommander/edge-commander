defmodule EdgeCommander.Repo.Migrations.CreateRouters do
  use Ecto.Migration

  def change do
    create table(:routers) do
      add :ip, :string
      add :username, :string
      add :password, :string
      add :port, :integer
      add :extra, :map
      add :name, :string
      add :router_status, :boolean, default: true, null: false
      add :is_monitoring, :boolean, default: false, null: false
      add :user_id, references(:users)

      timestamps()
    end

  end
end
