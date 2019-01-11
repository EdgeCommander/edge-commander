defmodule EdgeCommander.Repo.Migrations.AddMoreFieldsToBatteryReading do
  use Ecto.Migration

  def change do
  	alter table(:battery_reading) do
	  add :battery_id, :integer
	  add :il_value, :integer
	  add :mppt_value, :integer
	  add :load_value, :string
	end
  end
end
