defmodule EdgeCommander.RaidTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Raid

  describe "servers" do
    alias EdgeCommander.Raid.Server

    @valid_attrs %{ip: "some ip", password: "some password", username: "some username"}
    @update_attrs %{ip: "some updated ip", password: "some updated password", username: "some updated username"}
    @invalid_attrs %{ip: nil, password: nil, username: nil}

    def server_fixture(attrs \\ %{}) do
      {:ok, server} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Raid.create_server()

      server
    end

    test "list_servers/0 returns all servers" do
      server = server_fixture()
      assert Raid.list_servers() == [server]
    end

    test "get_server!/1 returns the server with given id" do
      server = server_fixture()
      assert Raid.get_server!(server.id) == server
    end

    test "create_server/1 with valid data creates a server" do
      assert {:ok, %Server{} = server} = Raid.create_server(@valid_attrs)
      assert server.ip == "some ip"
      assert server.password == "some password"
      assert server.username == "some username"
    end

    test "create_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Raid.create_server(@invalid_attrs)
    end

    test "update_server/2 with valid data updates the server" do
      server = server_fixture()
      assert {:ok, server} = Raid.update_server(server, @update_attrs)
      assert %Server{} = server
      assert server.ip == "some updated ip"
      assert server.password == "some updated password"
      assert server.username == "some updated username"
    end

    test "update_server/2 with invalid data returns error changeset" do
      server = server_fixture()
      assert {:error, %Ecto.Changeset{}} = Raid.update_server(server, @invalid_attrs)
      assert server == Raid.get_server!(server.id)
    end

    test "delete_server/1 deletes the server" do
      server = server_fixture()
      assert {:ok, %Server{}} = Raid.delete_server(server)
      assert_raise Ecto.NoResultsError, fn -> Raid.get_server!(server.id) end
    end

    test "change_server/1 returns a server changeset" do
      server = server_fixture()
      assert %Ecto.Changeset{} = Raid.change_server(server)
    end
  end
end
