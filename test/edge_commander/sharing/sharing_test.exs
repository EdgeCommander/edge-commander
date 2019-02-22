defmodule EdgeCommander.SharingTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Sharing

  describe "sharing" do
    alias EdgeCommander.Sharing.Member

    @valid_attrs %{sharer_id: 42, sharee_id: 42, account_id: 1, rights: 1}
    @update_attrs %{sharer_id: 43, sharee_id: 43, account_id: 2, rights: 2}
    @invalid_attrs %{sharer_id: nil, sharee_id: nil, account_id: nil, rights: nil}

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
      assert member.sharer_id == 42
      assert member.sharee_id == 42
      assert member.rights == 1
    end

    test "create_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sharing.create_member(@invalid_attrs)
    end

    test "update_member/2 with valid data updates the member" do
      member = member_fixture()
      assert {:ok, member} = Sharing.update_member(member, @update_attrs)
      assert %Member{} = member
      assert member.sharer_id == 43
      assert member.sharee_id == 43
      assert member.rights == 2
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
