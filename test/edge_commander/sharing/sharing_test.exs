defmodule EdgeCommander.SharingTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Sharing

  describe "sharing" do
    alias EdgeCommander.Sharing.Member

    @valid_attrs %{member_id: 42, role: 1, member_email: "some email", account_id: 1, token: "some token"}
    @update_attrs %{member_id: 43, role: 1, member_email: "some updated email", account_id: 2, token: "some updated token"}
    @invalid_attrs %{member_id: nil, role: nil, member_email: nil, account_id: nil, token: nil}

    def member_fixture(attrs \\ %{}) do
      {:ok, member} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sharing.create_member()

      member
    end

    test "get_member!/1 returns the member with given id" do
      member = member_fixture()
      assert Sharing.get_member!(member.id) == member
    end

    test "create_member/1 with valid data creates a member" do
      assert {:ok, %Member{} = member} = Sharing.create_member(@valid_attrs)
      assert member.member_id == 42
      assert member.role == 1
      assert member.member_email == "some email"
      assert member.token == "some token"
    end

    test "create_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sharing.create_member(@invalid_attrs)
    end

    test "update_member/2 with valid data updates the member" do
      member = member_fixture()
      assert {:ok, member} = Sharing.update_member(member, @update_attrs)
      assert %Member{} = member
      assert member.member_id == 43
      assert member.role == 1
      assert member.member_email == "some updated email"
      assert member.token == "some updated token"
    end

    test "update_member/2 with invalid data returns error changeset" do
      member = member_fixture()
      assert {:error, %Ecto.Changeset{}} = Sharing.update_member(member, @invalid_attrs)
      assert member == Sharing.get_member!(member.id)
    end

    test "delete_member/1 deletes the member" do
      member = member_fixture()
      assert {:ok, %Member{}} = Sharing.delete_member(member)
      assert_raise Ecto.NoResultsError, fn -> Sharing.get_member!(member.id) end
    end

    test "change_member/1 returns a member changeset" do
      member = member_fixture()
      assert %Ecto.Changeset{} = Sharing.change_member(member)
    end
  end
end
