defmodule EdgeCommander.DevicesTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Devices

  describe "nvrs" do
    alias EdgeCommander.Devices.Nvr

    @valid_attrs %{extra: %{}, firmware_version: "some firmware_version", ip: "110.39.130.42", is_monitoring: true, model: "some model", name: "some name", password: "some password", port: "80", vh_port: "8080", sdk_port: "9090", rtsp_port: "9000", username: "some username"}
    @update_attrs %{extra: %{}, firmware_version: "some updated firmware_version", ip: "110.39.130.98", is_monitoring: false, model: "some updated model", name: "some updated name", password: "some updated password", port: "81", vh_port: "8181", sdk_port: "9191", rtsp_port: "9001", username: "some updated username"}
    @invalid_attrs %{extra: nil, firmware_version: nil, ip: nil, is_monitoring: nil, model: nil, name: nil, password: nil, port: nil, vh_port: nil, sdk_port: nil, rtsp_port: nil, username: nil}

    def nvr_fixture(attrs \\ %{}) do
      {:ok, nvr} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Devices.create_nvr()
      nvr
    end

    test "get_nvr!/1 returns the nvr with given id" do
      nvr = nvr_fixture()
      assert Devices.get_nvr!(nvr.id) == nvr
    end

    test "create_nvr/1 with valid data creates a nvr" do
      assert {:ok, %Nvr{} = nvr} = Devices.create_nvr(@valid_attrs)
      assert nvr.extra == %{}
      assert nvr.firmware_version == "some firmware_version"
      assert nvr.ip == "110.39.130.42"
      assert nvr.is_monitoring == true
      assert nvr.model == "some model"
      assert nvr.name == "some name"
      assert nvr.password == "some password"
      assert nvr.port == 80
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
      assert nvr.ip == "110.39.130.98"
      assert nvr.is_monitoring == false
      assert nvr.model == "some updated model"
      assert nvr.name == "some updated name"
      assert nvr.password == "some updated password"
      assert nvr.port == 81
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

  describe "routers" do
    alias EdgeCommander.Devices.Router

    @valid_attrs %{extra: %{}, ip: "110.39.130.42", is_monitoring: true, name: "some name", password: "some password", port: 42, router_status: true, username: "some username"}
    @update_attrs %{extra: %{}, ip: "110.39.130.98", is_monitoring: false, name: "some updated name", password: "some updated password", port: 43, router_status: false, username: "some updated username"}
    @invalid_attrs %{extra: nil, ip: nil, is_monitoring: nil, name: nil, password: nil, port: nil, status: nil, username: nil}

    def router_fixture(attrs \\ %{}) do
      {:ok, router} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Devices.create_router()
      router
    end

    test "get_router!/1 returns the router with given id" do
      router = router_fixture()
      assert Devices.get_router!(router.id) == router
    end

    test "create_router/1 with valid data creates a router" do
      assert {:ok, %Router{} = router} = Devices.create_router(@valid_attrs)
      assert router.extra == %{}
      assert router.ip == "110.39.130.42"
      assert router.is_monitoring == true
      assert router.name == "some name"
      assert router.password == "some password"
      assert router.port == 42
      assert router.router_status == true
      assert router.username == "some username"
    end

    test "create_router/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_router(@invalid_attrs)
    end

    test "update_router/2 with valid data updates the router" do
      router = router_fixture()
      assert {:ok, router} = Devices.update_router(router, @update_attrs)
      assert %Router{} = router
      assert router.extra == %{}
      assert router.ip == "110.39.130.98"
      assert router.is_monitoring == false
      assert router.name == "some updated name"
      assert router.password == "some updated password"
      assert router.port == 43
      assert router.router_status == false
      assert router.username == "some updated username"
    end

    test "update_router/2 with invalid data returns error changeset" do
      router = router_fixture()
      assert {:error, %Ecto.Changeset{}} = Devices.update_router(router, @invalid_attrs)
      assert router == Devices.get_router!(router.id)
    end

    test "delete_router/1 deletes the router" do
      router = router_fixture()
      assert {:ok, %Router{}} = Devices.delete_router(router)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_router!(router.id) end
    end

    test "change_router/1 returns a router changeset" do
      router = router_fixture()
      assert %Ecto.Changeset{} = Devices.change_router(router)
    end
  end
end
