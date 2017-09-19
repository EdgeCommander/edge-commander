defmodule EdgeCommander.Repo.Migrations.CreateNvrPorts do
  use Ecto.Migration

  def change do
    create table(:nvr_ports) do
      add :nvr_id, :integer
      add :nvr_name, :string
      add :done_at, :utc_datetime
      add :nvr_created_at, :utc_datetime
      add :status, :boolean, default: false, null: false
      add :extra, :map

      timestamps()
    end

    create unique_index(:nvr_ports, [:nvr_id, :done_at], name: "nvr_ports_nvr_id_done_at_index")
  end
end
