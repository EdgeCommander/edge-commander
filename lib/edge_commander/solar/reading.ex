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
    field :p_value, :integer
    field :consumed_amphours, :integer
    field :soc_value, :integer
    field :time_to_go, :integer
    field :alarm, :string
    field :relay, :string
    field :ar_value, :integer
    field :bmv_value, :integer
    field :h1_value, :integer
    field :h2_value, :integer
    field :h3_value, :integer
    field :h4_value, :integer
    field :h5_value, :integer
    field :h6_value, :integer
    field :h7_value, :integer
    field :h8_value, :integer
    field :h9_value, :integer
    field :h10_value, :integer
    field :h11_value, :integer

    timestamps()
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:pid, :fw, :serial_no, :voltage, :i_value, :vpv_value, :ppv_value, :cs_value, :err_value, :h19_value, :h20_value, :h21_value, :h22_value, :h23_value, :datetime, :battery_id, :il_value, :mppt_value, :load_value, :p_value, :consumed_amphours, :soc_value, :time_to_go, :alarm, :relay, :ar_value, :bmv_value, :h1_value, :h2_value, :h3_value, :h4_value, :h5_value, :h6_value, :h7_value, :h8_value, :h9_value, :h10_value, :h11_value])
    |> validate_required([:pid, :fw, :serial_no, :voltage, :i_value, :vpv_value, :ppv_value, :cs_value, :err_value, :h19_value, :h20_value, :h21_value, :h22_value, :h23_value, :datetime, :battery_id, :il_value, :mppt_value, :load_value, :p_value, :consumed_amphours, :soc_value, :time_to_go, :alarm, :relay, :ar_value, :bmv_value, :h1_value, :h2_value, :h3_value, :h4_value, :h5_value, :h6_value, :h7_value, :h8_value, :h9_value, :h10_value, :h11_value])
  end
end
