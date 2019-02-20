defmodule EdgeCommander.Commands do
  import Ecto.Query, warn: false
  import EdgeCommander.ThreeScraper.Records, only: [all_sim_numbers: 0, get_last_record_for_number: 1]
  alias EdgeCommander.Repo
  alias EdgeCommander.Commands.Rule
  alias EdgeCommander.Sharing.Member
  require Logger

  def start_usage_command do
    get_active_usage_rules()
    |> Enum.map(fn(recipients) ->
      usage_command(recipients)
    end)
  end

  def get_active_usage_rules do
    Rule
    |> where(active: true)
    |> where(category: "usage_command")
    |> Repo.all
    |> Enum.map(fn(rule) ->
      rule.recipients
    end)
  end

  def usage_command(senders) do
    all_sim_numbers()
    |> Enum.map(fn(number) ->
      %EdgeCommander.ThreeScraper.SimLogs{
        volume_used: volume_used,
        allowance: allowance,
        addon: addon,
        name: name
      } = get_last_record_for_number(number)

      {current_in_number, _} = volume_used |> String.replace(",", "") |> Float.parse()
      {allowance_in_number, _} = allowance |> String.replace(",", "") |> Float.parse()

      percentage_used = (current_in_number / allowance_in_number * 100) |> Float.round(3)
      send_usage_email(senders, percentage_used, number, volume_used, allowance, name, addon)
    end)
  end

  def send_usage_email(_senders, usage, _number, _volume_used, _allowance, _name, _addon) when usage < 90, do: Logger.info "Usage is lower than 90%."
  def send_usage_email(senders, usage, number, volume_used, allowance, name, addon) do
    Application.get_env(:edge_commander, :send_emails_for_usage)
    |> send_email(senders, usage, number, volume_used, allowance, name, addon)
  end

  defp send_email(false, _senders, _usage, _number, _volume_used, _allowance, _name, _addon), do: Logger.info "Application is in dev mode."
  defp send_email(true, _senders, _usage, _number, _volume_used, _allowance, _name, _addon) do
    # EdgeCommander.EcMailer.usage_monitoring(senders, usage, number, volume_used, allowance, name, addon)
  end

  def list_rules(user_id) do
    query = from r in Rule,
      left_join: m in Member, on: r.user_id == m.account_id,
      where: (m.member_id == ^user_id or r.user_id == ^user_id),
      distinct: r.id,
      select: %{
          id: r.id,
          rule_name: r.rule_name,
          active: r.active,
          category: r.category,
          variable: r.variable,
          value: r.value,
          recipients: r.recipients,
          inserted_at: r.inserted_at
        }
    query
    |>  Repo.all
  end

  def get_rule!(id), do: Repo.get!(Rule, id)

  def create_rule(attrs \\ %{}) do
    %Rule{}
    |> Rule.changeset(attrs)
    |> Repo.insert()
  end

  def update_rule(%Rule{} = rule, attrs) do
    rule
    |> Rule.changeset(attrs)
    |> Repo.update()
  end

  def delete_rule(%Rule{} = rule) do
    Repo.delete(rule)
  end

  def change_rule(%Rule{} = rule) do
    Rule.changeset(rule, %{})
  end

  def get_active_sms_usage_rules(variable, value) do
    Rule
    |> where(active: true)
    |> where(category: "daily_sms_usage_command")
    |> where(variable: ^variable)
    |> where(value: ^value)
    |> Repo.all
    |> Enum.map(fn(rule) ->
      rule.recipients
    end)
  end

  def get_monthly_sms_usage_rules(variable, value) do
    Rule
    |> where(active: true)
    |> where(category: "monthly_sms_usage_command")
    |> where(variable: ^variable)
    |> where(value: ^value)
    |> Repo.all
    |> Enum.map(fn(rule) ->
      rule.recipients
    end)
  end

  def get_monthly_sms_usage_rules_list do
    Rule
    |> where(active: true)
    |> where(category: "monthly_sms_usage_command")
    |> Repo.all
  end

  def get_daily_sms_usage_rules_list do
    Rule
    |> where(active: true)
    |> where(category: "daily_sms_usage_command")
    |> Repo.all
  end

  def get_battery_voltages_rule_list do
    Rule
    |> where(active: true)
    |> where(category: "battery_voltages_command")
    |> Repo.all
  end

  def get_battery_voltages_rules(variable, value) do
    Rule
    |> where(active: true)
    |> where(category: "battery_voltages_command")
    |> where(variable: ^variable)
    |> where(value: ^value)
    |> Repo.all
    |> Enum.map(fn(rule) ->
      rule.recipients
    end)
  end
end
