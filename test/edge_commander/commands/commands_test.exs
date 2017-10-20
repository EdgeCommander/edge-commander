defmodule EdgeCommander.CommandsTest do
  use EdgeCommander.DataCase

  alias EdgeCommander.Commands

  describe "rules" do
    alias EdgeCommander.Commands.Rule

    @valid_attrs %{active: true, category: "some category", recipients: "some recipients", rule_name: "some rule_name"}
    @update_attrs %{active: false, category: "some updated category", recipients: "some updated recipients", rule_name: "some updated rule_name"}
    @invalid_attrs %{active: nil, category: nil, recipients: nil, rule_name: nil}

    def rule_fixture(attrs \\ %{}) do
      {:ok, rule} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Commands.create_rule()

      rule
    end

    test "list_rules/0 returns all rules" do
      rule = rule_fixture()
      assert Commands.list_rules() == [rule]
    end

    test "get_rule!/1 returns the rule with given id" do
      rule = rule_fixture()
      assert Commands.get_rule!(rule.id) == rule
    end

    test "create_rule/1 with valid data creates a rule" do
      assert {:ok, %Rule{} = rule} = Commands.create_rule(@valid_attrs)
      assert rule.active == true
      assert rule.category == "some category"
      assert rule.recipients == "some recipients"
      assert rule.rule_name == "some rule_name"
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
      assert rule.recipients == "some updated recipients"
      assert rule.rule_name == "some updated rule_name"
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
