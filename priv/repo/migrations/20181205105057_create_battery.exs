defmodule EdgeCommander.Repo.Migrations.CreateBattery do
  use Ecto.Migration

  def change do
    create table(:battery) do
      add :pid, :string
      add :fw, :string
      add :serial_no, :string
      add :voltage, :integer
      add :i_value, :integer
      add :vpv_value, :integer
      add :ppv_value, :integer
      add :cs_value, :integer
      add :err_value, :integer
      add :h19_value, :integer
      add :h20_value, :integer
      add :h21_value, :integer
      add :h22_value, :integer
      add :h23_value, :integer
      add :datetime, :string

      timestamps()
    end

  end
end
