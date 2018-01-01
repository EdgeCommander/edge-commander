defmodule EdgeCommander.SitesTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Sites

  describe "sites" do
    alias EdgeCommander.Sites.Records

    @valid_attrs %{location: "some location", name: "some name", notes: "some notes", nvr_id: 42, router_id: 42, sim_number: "some sim_number"}
    @update_attrs %{location: "some updated location", name: "some updated name", notes: "some updated notes", nvr_id: 43, router_id: 43, sim_number: "some updated sim_number"}
    @invalid_attrs %{location: nil, name: nil, notes: nil, nvr_id: nil, router_id: nil, sim_number: nil}

    def records_fixture(attrs \\ %{}) do
      {:ok, records} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sites.create_records()

      records
    end

    test "list_sites/0 returns all sites" do
      records = records_fixture()
      assert Sites.list_sites() == [records]
    end

    test "get_records!/1 returns the records with given id" do
      records = records_fixture()
      assert Sites.get_records!(records.id) == records
    end

    test "create_records/1 with valid data creates a records" do
      assert {:ok, %Records{} = records} = Sites.create_records(@valid_attrs)
      assert records.location == "some location"
      assert records.name == "some name"
      assert records.notes == "some notes"
      assert records.nvr_id == 42
      assert records.router_id == 42
      assert records.sim_number == "some sim_number"
    end

    test "create_records/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_records(@invalid_attrs)
    end

    test "update_records/2 with valid data updates the records" do
      records = records_fixture()
      assert {:ok, %Records{} = records} = Sites.update_records(records, @update_attrs)
      assert records.location == "some updated location"
      assert records.name == "some updated name"
      assert records.notes == "some updated notes"
      assert records.nvr_id == 43
      assert records.router_id == 43
      assert records.sim_number == "some updated sim_number"
    end

    test "update_records/2 with invalid data returns error changeset" do
      records = records_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.update_records(records, @invalid_attrs)
      assert records == Sites.get_records!(records.id)
    end

    test "delete_records/1 deletes the records" do
      records = records_fixture()
      assert {:ok, %Records{}} = Sites.delete_records(records)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_records!(records.id) end
    end

    test "change_records/1 returns a records changeset" do
      records = records_fixture()
      assert %Ecto.Changeset{} = Sites.change_records(records)
    end
  end
end
