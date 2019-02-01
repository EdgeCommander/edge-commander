defmodule EdgeCommander.SolarTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Solar

  describe "battery_reading" do
    alias EdgeCommander.Solar.Reading

    @valid_attrs %{datetime: "some datetime", err_value: 42, fw: "some fw", h19_value: 42, h20_value: 42, h21_value: 42, h22_value: 42, h23_value: 42, i_value: 42, cs_value: 42, pid: "some pid", ppv_value: 42, serial_no: "some serial_no", voltage: 42, vpv_value: 42, battery_id: 42, il_value: 42, mppt_value: 42, load_value: "ON", p_value: 42, consumed_amphours: 42, soc_value: 42, time_to_go: 42, alarm: "ON", relay: "ON", ar_value: 42, h1_value: 42, h2_value: 42, h3_value: 42, h4_value: 42, h5_value: 42, h6_value: 42, h7_value: 42, h8_value: 42, h9_value: 42, h10_value: 42, h11_value: 42, bmv_value: 42}
    @invalid_attrs %{datetime: nil, err_value: nil, fw: nil, h19_value: nil, h20_value: nil, h21_value: nil, h22_value: nil, h23_value: nil, i_value: nil, cs_value: nil, pid: nil, ppv_value: nil, serial_no: nil, voltage: nil, vpv_value: nil, battery_id: nil, il_value: nil, mppt_value: nil, load_value: nil, p_value: nil, consumed_amphours: nil, soc_value: nil, time_to_go: nil, alarm: "ON", relay: "ON", ar_value: nil, h1_value: nil, h2_value: nil, h3_value: nil, h4_value: nil, h5_value: nil, h6_value: nil, h7_value: nil, h8_value: nil, h9_value: nil, h10_value: nil, h11_value: nil, bmv_value: nil}

    def battery_reading_fixture(attrs \\ %{}) do
      {:ok, reading} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Solar.create_reading()

      reading
    end

    test "list_reading/0 returns all battery" do
      reading = battery_reading_fixture()
      assert Solar.list_reading() == [reading]
    end

    test "get_reading!/1 returns the battery with given id" do
      reading = battery_reading_fixture()
      assert Solar.get_reading!(reading.id) == reading
    end

    test "create_reading/1 with valid data creates a battery" do
      assert {:ok, %Reading{} = reading} = Solar.create_reading(@valid_attrs)
      assert reading.datetime == "some datetime"
      assert reading.err_value == 42
      assert reading.fw == "some fw"
      assert reading.h19_value == 42
      assert reading.h20_value == 42
      assert reading.h21_value == 42
      assert reading.h22_value == 42
      assert reading.h23_value == 42
      assert reading.i_value == 42
      assert reading.cs_value == 42
      assert reading.pid == "some pid"
      assert reading.ppv_value == 42
      assert reading.serial_no == "some serial_no"
      assert reading.voltage == 42
      assert reading.vpv_value == 42
      assert reading.battery_id == 42
      assert reading.il_value == 42
      assert reading.mppt_value == 42
      assert reading.load_value == "ON"
      assert reading.p_value == 42
      assert reading.consumed_amphours == 42
      assert reading.soc_value == 42
      assert reading.time_to_go == 42
      assert reading.alarm == "ON"
      assert reading.relay == "ON"
      assert reading.ar_value == 42
      assert reading.h1_value == 42
      assert reading.h2_value == 42
      assert reading.h3_value == 42
      assert reading.h4_value == 42
      assert reading.h5_value == 42
      assert reading.h6_value == 42
      assert reading.h7_value == 42
      assert reading.h8_value == 42
      assert reading.h9_value == 42
      assert reading.h10_value == 42
      assert reading.h11_value == 42
      assert reading.bmv_value == 42
    end

    test "create_reading/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Solar.create_reading(@invalid_attrs)
    end

    test "update_reading/2 with invalid data returns error changeset" do
      reading = battery_reading_fixture()
      assert {:error, %Ecto.Changeset{}} = Solar.update_reading(reading, @invalid_attrs)
      assert reading == Solar.get_reading!(reading.id)
    end

    test "delete_reading/1 deletes the battery" do
      reading = battery_reading_fixture()
      assert {:ok, %Reading{}} = Solar.delete_reading(reading)
      assert_raise Ecto.NoResultsError, fn -> Solar.get_reading!(reading.id) end
    end

    test "change_reading/1 returns a battery changeset" do
      reading = battery_reading_fixture()
      assert %Ecto.Changeset{} = Solar.change_reading(reading)
    end
  end
end
