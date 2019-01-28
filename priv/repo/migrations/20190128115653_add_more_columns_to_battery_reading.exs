defmodule EdgeCommander.Repo.Migrations.AddMoreColumnsToBatteryReading do
  use Ecto.Migration

  def change do
  	alter table(:battery_reading) do
	  add :p_value, :integer
	  add :consumed_amphours, :integer
	  add :soc_value, :integer
	  add :time_to_go, :integer
	  add :alarm, :string
	  add :relay, :string
	  add :ar_value, :integer
	  add :bmv_value, :integer
	  add :h1_value, :integer
	  add :h2_value, :integer
	  add :h3_value, :integer
	  add :h4_value, :integer
	  add :h5_value, :integer
	  add :h6_value, :integer
	  add :h7_value, :integer
	  add :h8_value, :integer
	  add :h9_value, :integer
	  add :h10_value, :integer
	  add :h11_value, :integer
	end
  end
end