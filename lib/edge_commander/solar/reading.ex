defmodule EdgeCommander.Solar.Reading do
  use Ecto.Schema
  import Ecto.Changeset


  schema "battery_reading" do
    field :datetime, :string
    field :err_value, :integer
    field :fw, :string
    field :h19_value, :integer
    field :h20_value, :integer
    field :h21_value, :integer
    field :h22_value, :integer
    field :h23_value, :integer
    field :i_value, :integer
    field :cs_value, :integer
    field :pid, :string
    field :ppv_value, :integer
    field :serial_no, :string
    field :voltage, :integer
    field :vpv_value, :integer
    field :battery_id, :integer
    field :il_value, :integer
    field :mppt_value, :integer
    field :load_value, :string

    timestamps()
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:pid, :fw, :serial_no, :voltage, :i_value, :vpv_value, :ppv_value, :cs_value, :err_value, :h19_value, :h20_value, :h21_value, :h22_value, :h23_value, :datetime, :battery_id, :il_value, :mppt_value, :load_value])
    |> validate_required([:pid, :fw, :serial_no, :voltage, :i_value, :vpv_value, :ppv_value, :cs_value, :err_value, :h19_value, :h20_value, :h21_value, :h22_value, :h23_value, :datetime, :battery_id, :il_value, :mppt_value, :load_value])
  end
end
