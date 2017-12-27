defmodule EdgeCommander.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :name, :string
      add :location, :string
      add :sim_number, :integer
      add :router_id, :integer
      add :nvr_id, :integer
      add :notes, :string
      add :user_id, references(:users)

      timestamps()
    end

  end
end
