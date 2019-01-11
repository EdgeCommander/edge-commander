defmodule EdgeCommander.Repo.Migrations.RenameBatteryTableToBatteryReading do
  use Ecto.Migration

  def change do
	rename table(:battery), to: table(:battery_reading)
  end
end
