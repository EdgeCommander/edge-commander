defmodule EdgeCommander.ActivityTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Activity

  describe "logs" do
    alias EdgeCommander.Activity.Logs

    @valid_attrs %{browser: "some browser", country: "some country", country_code: "some country_code", event: "some event", ip: "some ip", platform: "some platform", user_id: 42}
    @update_attrs %{browser: "some updated browser", country: "some updated country", country_code: "some updated country_code", event: "some updated event", ip: "some updated ip", platform: "some updated platform", user_id: 43}
    @invalid_attrs %{browser: nil, country: nil, country_code: nil, event: nil, ip: nil, platform: nil, user_id: nil}

    def logs_fixture(attrs \\ %{}) do
      {:ok, logs} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Activity.create_logs()

      logs
    end

    test "list_logs/0 returns all logs" do
      logs = logs_fixture()
      assert Activity.list_logs() == [logs]
    end

    test "get_logs!/1 returns the logs with given id" do
      logs = logs_fixture()
      assert Activity.get_logs!(logs.id) == logs
    end

    test "create_logs/1 with valid data creates a logs" do
      assert {:ok, %Logs{} = logs} = Activity.create_logs(@valid_attrs)
      assert logs.browser == "some browser"
      assert logs.country == "some country"
      assert logs.country_code == "some country_code"
      assert logs.event == "some event"
      assert logs.ip == "some ip"
      assert logs.platform == "some platform"
      assert logs.user_id == 42
    end

    test "create_logs/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activity.create_logs(@invalid_attrs)
    end

    test "update_logs/2 with valid data updates the logs" do
      logs = logs_fixture()
      assert {:ok, logs} = Activity.update_logs(logs, @update_attrs)
      assert %Logs{} = logs
      assert logs.browser == "some updated browser"
      assert logs.country == "some updated country"
      assert logs.country_code == "some updated country_code"
      assert logs.event == "some updated event"
      assert logs.ip == "some updated ip"
      assert logs.platform == "some updated platform"
      assert logs.user_id == 43
    end

    test "update_logs/2 with invalid data returns error changeset" do
      logs = logs_fixture()
      assert {:error, %Ecto.Changeset{}} = Activity.update_logs(logs, @invalid_attrs)
      assert logs == Activity.get_logs!(logs.id)
    end

    test "delete_logs/1 deletes the logs" do
      logs = logs_fixture()
      assert {:ok, %Logs{}} = Activity.delete_logs(logs)
      assert_raise Ecto.NoResultsError, fn -> Activity.get_logs!(logs.id) end
    end

    test "change_logs/1 returns a logs changeset" do
      logs = logs_fixture()
      assert %Ecto.Changeset{} = Activity.change_logs(logs)
    end
  end
end
