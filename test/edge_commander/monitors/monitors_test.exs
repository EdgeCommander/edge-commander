defmodule EdgeCommander.MonitorsTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Monitors

  describe "nvr_ports" do
    alias EdgeCommander.Monitors.NvrPorts

    @valid_attrs %{done_at: "2010-04-17 14:00:00.000000Z", extra: %{}, nvr_id: 42, nvr_name: "some nvr_name", status: true}
    @update_attrs %{done_at: "2011-05-18 15:01:01.000000Z", extra: %{}, nvr_id: 43, nvr_name: "some updated nvr_name", status: false}
    @invalid_attrs %{done_at: nil, extra: nil, nvr_id: nil, nvr_name: nil, status: nil}

    def nvr_ports_fixture(attrs \\ %{}) do
      {:ok, nvr_ports} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Monitors.create_nvr_ports()

      nvr_ports
    end

    test "list_nvr_ports/0 returns all nvr_ports" do
      nvr_ports = nvr_ports_fixture()
      assert Monitors.list_nvr_ports() == [nvr_ports]
    end

    test "get_nvr_ports!/1 returns the nvr_ports with given id" do
      nvr_ports = nvr_ports_fixture()
      assert Monitors.get_nvr_ports!(nvr_ports.id) == nvr_ports
    end

    test "create_nvr_ports/1 with valid data creates a nvr_ports" do
      assert {:ok, %NvrPorts{} = nvr_ports} = Monitors.create_nvr_ports(@valid_attrs)
      assert nvr_ports.done_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert nvr_ports.extra == %{}
      assert nvr_ports.nvr_id == 42
      assert nvr_ports.nvr_name == "some nvr_name"
      assert nvr_ports.status == true
    end

    test "create_nvr_ports/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Monitors.create_nvr_ports(@invalid_attrs)
    end

    test "update_nvr_ports/2 with valid data updates the nvr_ports" do
      nvr_ports = nvr_ports_fixture()
      assert {:ok, nvr_ports} = Monitors.update_nvr_ports(nvr_ports, @update_attrs)
      assert %NvrPorts{} = nvr_ports
      assert nvr_ports.done_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert nvr_ports.extra == %{}
      assert nvr_ports.nvr_id == 43
      assert nvr_ports.nvr_name == "some updated nvr_name"
      assert nvr_ports.status == false
    end

    test "update_nvr_ports/2 with invalid data returns error changeset" do
      nvr_ports = nvr_ports_fixture()
      assert {:error, %Ecto.Changeset{}} = Monitors.update_nvr_ports(nvr_ports, @invalid_attrs)
      assert nvr_ports == Monitors.get_nvr_ports!(nvr_ports.id)
    end

    test "delete_nvr_ports/1 deletes the nvr_ports" do
      nvr_ports = nvr_ports_fixture()
      assert {:ok, %NvrPorts{}} = Monitors.delete_nvr_ports(nvr_ports)
      assert_raise Ecto.NoResultsError, fn -> Monitors.get_nvr_ports!(nvr_ports.id) end
    end

    test "change_nvr_ports/1 returns a nvr_ports changeset" do
      nvr_ports = nvr_ports_fixture()
      assert %Ecto.Changeset{} = Monitors.change_nvr_ports(nvr_ports)
    end
  end
end
