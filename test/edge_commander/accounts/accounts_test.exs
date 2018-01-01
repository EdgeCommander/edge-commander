defmodule EdgeCommander.AccountsTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Accounts

  describe "users" do
    alias EdgeCommander.Accounts.User

    @valid_attrs %{email: "some email", password: "some password", username: "some username", lastname: "some lastname", firstname: "some firstname"}
    @update_attrs %{email: "some updated email", password: "some updated password", username: "some updated username", lastname: "some updated lastname", firstname: "some updated firstname"}
    @invalid_attrs %{email: nil, password: nil, username: nil, lastname: nil, firstname: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() |> List.first |> Map.delete(:last_signed_in) == [user] |> List.first |> Map.delete(:last_signed_in)
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) |> Map.delete(:last_signed_in) == user |> Map.delete(:last_signed_in)
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.username == "some username"
      assert user.lastname == "some lastname"
      assert user.firstname == "some firstname"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some updated email"
      assert user.username == "some updated username"
      assert user.lastname == "some updated lastname"
      assert user.firstname == "some updated firstname"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user |> Map.delete(:last_signed_in) == Accounts.get_user!(user.id) |> Map.delete(:last_signed_in)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
