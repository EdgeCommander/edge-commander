defmodule EdgeCommander.Repo.Migrations.AddMorePortsToNvr do
  use Ecto.Migration

  def change do
    alter table(:nvrs) do
      add :vh_port, :integer
      add :sdk_port, :integer
      add :rtsp_port, :integer
    end
  end
end
