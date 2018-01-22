defmodule EdgeCommander.NexmoTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Nexmo

  describe "sms_messages" do
    alias EdgeCommander.Nexmo.SimMessages

    @valid_attrs %{from: "some from", message_id: "some message_id", status: "some status", text: "some text", to: "some to", type: "some type", user_id: 42}
    @update_attrs %{from: "some updated from", message_id: "some updated message_id", status: "some updated status", text: "some updated text", to: "some updated to", type: "some updated type", user_id: 43}
    @invalid_attrs %{from: nil, message_id: nil, status: nil, text: nil, to: nil, type: nil, user_id: nil}

    def sim_messages_fixture(attrs \\ %{}) do
      {:ok, sim_messages} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Nexmo.create_sim_messages()

      sim_messages
    end

    test "list_sms_messages/0 returns all sms_messages" do
      from_date = "2018-01-20";
      to_date = "2018-01-22";
      sim_messages = sim_messages_fixture()
      assert Nexmo.list_sms_messages(from_date, to_date) == [sim_messages]
    end

    test "get_sim_messages!/1 returns the sim_messages with given id" do
      sim_messages = sim_messages_fixture()
      assert Nexmo.get_sim_messages!(sim_messages.id) == sim_messages
    end

    test "create_sim_messages/1 with valid data creates a sim_messages" do
      assert {:ok, %SimMessages{} = sim_messages} = Nexmo.create_sim_messages(@valid_attrs)
      assert sim_messages.from == "some from"
      assert sim_messages.message_id == "some message_id"
      assert sim_messages.status == "some status"
      assert sim_messages.text == "some text"
      assert sim_messages.to == "some to"
      assert sim_messages.type == "some type"
      assert sim_messages.user_id == 42
    end

    test "create_sim_messages/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Nexmo.create_sim_messages(@invalid_attrs)
    end

    test "update_sim_messages/2 with valid data updates the sim_messages" do
      sim_messages = sim_messages_fixture()
      assert {:ok, sim_messages} = Nexmo.update_sim_messages(sim_messages, @update_attrs)
      assert %SimMessages{} = sim_messages
      assert sim_messages.from == "some updated from"
      assert sim_messages.message_id == "some updated message_id"
      assert sim_messages.status == "some updated status"
      assert sim_messages.text == "some updated text"
      assert sim_messages.to == "some updated to"
      assert sim_messages.type == "some updated type"
      assert sim_messages.user_id == 43
    end

    test "update_sim_messages/2 with invalid data returns error changeset" do
      sim_messages = sim_messages_fixture()
      assert {:error, %Ecto.Changeset{}} = Nexmo.update_sim_messages(sim_messages, @invalid_attrs)
      assert sim_messages == Nexmo.get_sim_messages!(sim_messages.id)
    end

    test "delete_sim_messages/1 deletes the sim_messages" do
      sim_messages = sim_messages_fixture()
      assert {:ok, %SimMessages{}} = Nexmo.delete_sim_messages(sim_messages)
      assert_raise Ecto.NoResultsError, fn -> Nexmo.get_sim_messages!(sim_messages.id) end
    end

    test "change_sim_messages/1 returns a sim_messages changeset" do
      sim_messages = sim_messages_fixture()
      assert %Ecto.Changeset{} = Nexmo.change_sim_messages(sim_messages)
    end
  end
end
