defmodule EdgeCommander.DevicesTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Devices

  describe "nvrs" do
    alias EdgeCommander.Devices.Nvr

    @valid_attrs %{extra: %{}, firmware_version: "some firmware_version", ip: "some ip", is_monitoring: true, model: "some model", name: "some name", password: "some password", port: "some port", username: "some username"}
    @update_attrs %{extra: %{}, firmware_version: "some updated firmware_version", ip: "some updated ip", is_monitoring: false, model: "some updated model", name: "some updated name", password: "some updated password", port: "some updated port", username: "some updated username"}
    @invalid_attrs %{extra: nil, firmware_version: nil, ip: nil, is_monitoring: nil, model: nil, name: nil, password: nil, port: nil, username: nil}

    def nvr_fixture(attrs \\ %{}) do
      {:ok, nvr} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Devices.create_nvr()

      nvr
    end

    test "list_nvrs/0 returns all nvrs" do
      nvr = nvr_fixture()
      assert Devices.list_nvrs() == [nvr]
    end

    test "get_nvr!/1 returns the nvr with given id" do
      nvr = nvr_fixture()
      assert Devices.get_nvr!(nvr.id) == nvr
    end

    test "create_nvr/1 with valid data creates a nvr" do
      assert {:ok, %Nvr{} = nvr} = Devices.create_nvr(@valid_attrs)
      assert nvr.extra == %{}
      assert nvr.firmware_version == "some firmware_version"
      assert nvr.ip == "some ip"
      assert nvr.is_monitoring == true
      assert nvr.model == "some model"
      assert nvr.name == "some name"
      assert nvr.password == "some password"
      assert nvr.port == "some port"
      assert nvr.username == "some username"
    end

    test "create_nvr/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_nvr(@invalid_attrs)
    end

    test "update_nvr/2 with valid data updates the nvr" do
      nvr = nvr_fixture()
      assert {:ok, nvr} = Devices.update_nvr(nvr, @update_attrs)
      assert %Nvr{} = nvr
      assert nvr.extra == %{}
      assert nvr.firmware_version == "some updated firmware_version"
      assert nvr.ip == "some updated ip"
      assert nvr.is_monitoring == false
      assert nvr.model == "some updated model"
      assert nvr.name == "some updated name"
      assert nvr.password == "some updated password"
      assert nvr.port == "some updated port"
      assert nvr.username == "some updated username"
    end

    test "update_nvr/2 with invalid data returns error changeset" do
      nvr = nvr_fixture()
      assert {:error, %Ecto.Changeset{}} = Devices.update_nvr(nvr, @invalid_attrs)
      assert nvr == Devices.get_nvr!(nvr.id)
    end

    test "delete_nvr/1 deletes the nvr" do
      nvr = nvr_fixture()
      assert {:ok, %Nvr{}} = Devices.delete_nvr(nvr)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_nvr!(nvr.id) end
    end

    test "change_nvr/1 returns a nvr changeset" do
      nvr = nvr_fixture()
      assert %Ecto.Changeset{} = Devices.change_nvr(nvr)
    end
  end
end
