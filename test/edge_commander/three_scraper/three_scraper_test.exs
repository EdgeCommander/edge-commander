defmodule EdgeCommander.ThreeScraperTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.ThreeScraper.Records

  describe "sim_logs" do
    alias EdgeCommander.ThreeScraper.SimLogs

    @valid_attrs %{addon: "some addon", allowance: "some allowance", datetime: ~N[2010-04-17 14:00:00.000000], name: "some name", number: "some number", volume_used: "some volume_used", sim_provider: "some sim_provider"}
    @update_attrs %{addon: "some updated addon", allowance: "some updated allowance", datetime: ~N[2011-05-18 15:01:01.000000], name: "some updated name", number: "some updated number", volume_used: "some updated volume_used", sim_provider: "some updated sim_provider"}
    @invalid_attrs %{addon: nil, allowance: nil, datetime: nil, name: nil, number: nil, volume_used: nil, sim_provider: nil}

    def sim_logs_fixture(attrs \\ %{}) do
      {:ok, sim_logs} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Records.create_sim_logs()

      sim_logs
    end

    test "list_sim_logs/0 returns all sim_logs" do
      sim_logs = sim_logs_fixture()
      assert Records.list_sim_logs() == [sim_logs]
    end

    test "get_sim_logs!/1 returns the sim_logs with given id" do
      sim_logs = sim_logs_fixture()
      assert Records.get_sim_logs!(sim_logs.id) == sim_logs
    end

    test "create_sim_logs/1 with valid data creates a sim_logs" do
      assert {:ok, %SimLogs{} = sim_logs} = Records.create_sim_logs(@valid_attrs)
      assert sim_logs.addon == "some addon"
      assert sim_logs.allowance == "some allowance"
      assert sim_logs.datetime == ~N[2010-04-17 14:00:00]
      assert sim_logs.name == "some name"
      assert sim_logs.number == "some number"
      assert sim_logs.volume_used == "some volume_used"
      assert sim_logs.sim_provider == "some sim_provider"
    end

    test "create_sim_logs/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Records.create_sim_logs(@invalid_attrs)
    end

    test "update_sim_logs/2 with valid data updates the sim_logs" do
      sim_logs = sim_logs_fixture()
      assert {:ok, sim_logs} = Records.update_sim_logs(sim_logs, @update_attrs)
      assert %SimLogs{} = sim_logs
      assert sim_logs.addon == "some updated addon"
      assert sim_logs.allowance == "some updated allowance"
      assert sim_logs.datetime == ~N[2011-05-18 15:01:01]
      assert sim_logs.name == "some updated name"
      assert sim_logs.number == "some updated number"
      assert sim_logs.volume_used == "some updated volume_used"
      assert sim_logs.sim_provider == "some updated sim_provider"
    end

    test "update_sim_logs/2 with invalid data returns error changeset" do
      sim_logs = sim_logs_fixture()
      assert {:error, %Ecto.Changeset{}} = Records.update_sim_logs(sim_logs, @invalid_attrs)
      assert sim_logs == Records.get_sim_logs!(sim_logs.id)
    end

    test "delete_sim_logs/1 deletes the sim_logs" do
      sim_logs = sim_logs_fixture()
      assert {:ok, %SimLogs{}} = Records.delete_sim_logs(sim_logs)
      assert_raise Ecto.NoResultsError, fn -> Records.get_sim_logs!(sim_logs.id) end
    end

    test "change_sim_logs/1 returns a sim_logs changeset" do
      sim_logs = sim_logs_fixture()
      assert %Ecto.Changeset{} = Records.change_sim_logs(sim_logs)
    end
  end
end
