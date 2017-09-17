defmodule EdgeCommander.ThreeScraperTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.ThreeScraper

  describe "sim_logs" do
    alias EdgeCommander.ThreeScraper.SimLogs

    @valid_attrs %{addon: "some addon", allowance: "some allowance", datatime: ~N[2010-04-17 14:00:00.000000], name: "some name", number: "some number", volume_used: "some volume_used"}
    @update_attrs %{addon: "some updated addon", allowance: "some updated allowance", datatime: ~N[2011-05-18 15:01:01.000000], name: "some updated name", number: "some updated number", volume_used: "some updated volume_used"}
    @invalid_attrs %{addon: nil, allowance: nil, datatime: nil, name: nil, number: nil, volume_used: nil}

    def sim_logs_fixture(attrs \\ %{}) do
      {:ok, sim_logs} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ThreeScraper.create_sim_logs()

      sim_logs
    end

    test "list_sim_logs/0 returns all sim_logs" do
      sim_logs = sim_logs_fixture()
      assert ThreeScraper.list_sim_logs() == [sim_logs]
    end

    test "get_sim_logs!/1 returns the sim_logs with given id" do
      sim_logs = sim_logs_fixture()
      assert ThreeScraper.get_sim_logs!(sim_logs.id) == sim_logs
    end

    test "create_sim_logs/1 with valid data creates a sim_logs" do
      assert {:ok, %SimLogs{} = sim_logs} = ThreeScraper.create_sim_logs(@valid_attrs)
      assert sim_logs.addon == "some addon"
      assert sim_logs.allowance == "some allowance"
      assert sim_logs.datatime == ~N[2010-04-17 14:00:00.000000]
      assert sim_logs.name == "some name"
      assert sim_logs.number == "some number"
      assert sim_logs.volume_used == "some volume_used"
    end

    test "create_sim_logs/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ThreeScraper.create_sim_logs(@invalid_attrs)
    end

    test "update_sim_logs/2 with valid data updates the sim_logs" do
      sim_logs = sim_logs_fixture()
      assert {:ok, sim_logs} = ThreeScraper.update_sim_logs(sim_logs, @update_attrs)
      assert %SimLogs{} = sim_logs
      assert sim_logs.addon == "some updated addon"
      assert sim_logs.allowance == "some updated allowance"
      assert sim_logs.datatime == ~N[2011-05-18 15:01:01.000000]
      assert sim_logs.name == "some updated name"
      assert sim_logs.number == "some updated number"
      assert sim_logs.volume_used == "some updated volume_used"
    end

    test "update_sim_logs/2 with invalid data returns error changeset" do
      sim_logs = sim_logs_fixture()
      assert {:error, %Ecto.Changeset{}} = ThreeScraper.update_sim_logs(sim_logs, @invalid_attrs)
      assert sim_logs == ThreeScraper.get_sim_logs!(sim_logs.id)
    end

    test "delete_sim_logs/1 deletes the sim_logs" do
      sim_logs = sim_logs_fixture()
      assert {:ok, %SimLogs{}} = ThreeScraper.delete_sim_logs(sim_logs)
      assert_raise Ecto.NoResultsError, fn -> ThreeScraper.get_sim_logs!(sim_logs.id) end
    end

    test "change_sim_logs/1 returns a sim_logs changeset" do
      sim_logs = sim_logs_fixture()
      assert %Ecto.Changeset{} = ThreeScraper.change_sim_logs(sim_logs)
    end
  end
end
