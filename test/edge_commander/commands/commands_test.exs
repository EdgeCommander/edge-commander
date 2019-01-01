defmodule EdgeCommander.CommandsTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Commands

  describe "rules" do
    alias EdgeCommander.Commands.Rule

    @valid_attrs %{active: true, category: "some category", recipients: ["test@user.com"], rule_name: "some rule_name", variable: "less_than", value: 42}
    @update_attrs %{active: false, category: "some updated category", recipients: ["who@am.io"], rule_name: "some updated rule_name", variable: "less_than", value: 43}
    @invalid_attrs %{active: nil, category: nil, recipients: [], rule_name: nil, variable: nil, value: nil}

    def rule_fixture(attrs \\ %{}) do
      {:ok, rule} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Commands.create_rule()
      rule
    end

    test "get_rule!/1 returns the rule with given id" do
      rule = rule_fixture()
      assert Commands.get_rule!(rule.id) == rule
    end

    test "create_rule/1 with valid data creates a rule" do
      assert {:ok, %Rule{} = rule} = Commands.create_rule(@valid_attrs)
      assert rule.active == true
      assert rule.category == "some category"
      assert rule.recipients == ["test@user.com"]
      assert rule.rule_name == "some rule_name"
      assert rule.variable == "less_than"
      assert rule.value == 42
    end

    test "create_rule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Commands.create_rule(@invalid_attrs)
    end

    test "update_rule/2 with valid data updates the rule" do
      rule = rule_fixture()
      assert {:ok, rule} = Commands.update_rule(rule, @update_attrs)
      assert %Rule{} = rule
      assert rule.active == false
      assert rule.category == "some updated category"
      assert rule.recipients == ["who@am.io"]
      assert rule.rule_name == "some updated rule_name"
      assert rule.variable == "less_than"
      assert rule.value == 43
    end

    test "update_rule/2 with invalid data returns error changeset" do
      rule = rule_fixture()
      assert {:error, %Ecto.Changeset{}} = Commands.update_rule(rule, @invalid_attrs)
      assert rule == Commands.get_rule!(rule.id)
    end

    test "delete_rule/1 deletes the rule" do
      rule = rule_fixture()
      assert {:ok, %Rule{}} = Commands.delete_rule(rule)
      assert_raise Ecto.NoResultsError, fn -> Commands.get_rule!(rule.id) end
    end

    test "change_rule/1 returns a rule changeset" do
      rule = rule_fixture()
      assert %Ecto.Changeset{} = Commands.change_rule(rule)
    end
  end
end
