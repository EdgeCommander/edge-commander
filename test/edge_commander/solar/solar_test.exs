defmodule EdgeCommander.SolarTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Solar

  describe "battery" do
    alias EdgeCommander.Solar.Battery

    @valid_attrs %{datetime: "some datetime", err_value: 42, fw: "some fw", h19_value: 42, h20_value: 42, h21_value: 42, h22_value: 42, h23_value: 42, i_value: 42, cs_value: 42, pid: "some pid", ppv_value: 42, serial_no: "some serial_no", voltage: 42, vpv_value: 42}
    @update_attrs %{datetime: "some updated datetime", err_value: 43, fw: "some updated fw", h19_value: 43, h20_value: 43, h21_value: 43, h22_value: 43, h23_value: 43, i_value: 43, cs_value: 43, pid: "some updated pid", ppv_value: 43, serial_no: "some updated serial_no", voltage: 43, vpv_value: 43}
    @invalid_attrs %{datetime: nil, err_value: nil, fw: nil, h19_value: nil, h20_value: nil, h21_value: nil, h22_value: nil, h23_value: nil, i_value: nil, cs_value: nil, pid: nil, ppv_value: nil, serial_no: nil, voltage: nil, vpv_value: nil}

    def battery_fixture(attrs \\ %{}) do
      {:ok, battery} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Solar.create_battery()

      battery
    end

    test "list_battery/0 returns all battery" do
      battery = battery_fixture()
      assert Solar.list_battery() == [battery]
    end

    test "get_battery!/1 returns the battery with given id" do
      battery = battery_fixture()
      assert Solar.get_battery!(battery.id) == battery
    end

    test "create_battery/1 with valid data creates a battery" do
      assert {:ok, %Battery{} = battery} = Solar.create_battery(@valid_attrs)
      assert battery.datetime == "some datetime"
      assert battery.err_value == 42
      assert battery.fw == "some fw"
      assert battery.h19_value == 42
      assert battery.h20_value == 42
      assert battery.h21_value == 42
      assert battery.h22_value == 42
      assert battery.h23_value == 42
      assert battery.i_value == 42
      assert battery.cs_value == 42
      assert battery.pid == "some pid"
      assert battery.ppv_value == 42
      assert battery.serial_no == "some serial_no"
      assert battery.voltage == 42
      assert battery.vpv_value == 42
    end

    test "create_battery/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Solar.create_battery(@invalid_attrs)
    end

    test "update_battery/2 with valid data updates the battery" do
      battery = battery_fixture()
      assert {:ok, battery} = Solar.update_battery(battery, @update_attrs)
      assert %Battery{} = battery
      assert battery.datetime == "some updated datetime"
      assert battery.err_value == 43
      assert battery.fw == "some updated fw"
      assert battery.h19_value == 43
      assert battery.h20_value == 43
      assert battery.h21_value == 43
      assert battery.h22_value == 43
      assert battery.h23_value == 43
      assert battery.i_value == 43
      assert battery.cs_value == 43
      assert battery.pid == "some updated pid"
      assert battery.ppv_value == 43
      assert battery.serial_no == "some updated serial_no"
      assert battery.voltage == 43
      assert battery.vpv_value == 43
    end

    test "update_battery/2 with invalid data returns error changeset" do
      battery = battery_fixture()
      assert {:error, %Ecto.Changeset{}} = Solar.update_battery(battery, @invalid_attrs)
      assert battery == Solar.get_battery!(battery.id)
    end

    test "delete_battery/1 deletes the battery" do
      battery = battery_fixture()
      assert {:ok, %Battery{}} = Solar.delete_battery(battery)
      assert_raise Ecto.NoResultsError, fn -> Solar.get_battery!(battery.id) end
    end

    test "change_battery/1 returns a battery changeset" do
      battery = battery_fixture()
      assert %Ecto.Changeset{} = Solar.change_battery(battery)
    end
  end
end
