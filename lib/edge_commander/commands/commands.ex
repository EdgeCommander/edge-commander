defmodule EdgeCommander.Commands do
  import Ecto.Query, warn: false
  import EdgeCommander.ThreeScraper, only: [all_sim_numbers: 0, get_last_record_for_number: 1]
  alias EdgeCommander.Repo
  alias EdgeCommander.Commands.Rule
  require Logger

  def usage_command do
    all_sim_numbers()
    |> Enum.map(fn(number) ->
      %EdgeCommander.ThreeScraper.SimLogs{
        volume_used: volume_used,
        allowance: allowance,
        name: name
      } = get_last_record_for_number(number)

      {current_in_number, _} = volume_used |> String.replace(",", "") |> Float.parse()
      {allowance_in_number, _} = allowance |> String.replace(",", "") |> Float.parse()

      percentage_used = (current_in_number / allowance_in_number * 100) |> Float.round(3)
      send_usage_email(percentage_used, number, volume_used, allowance, name)
    end)
  end

  def send_usage_email(usage, _number, _volume_used, _allowance, _name) when usage < 90, do: Logger.info "Usage is lower than 90%."
  def send_usage_email(usage, number, volume_used, allowance, name) do
    Application.get_env(:edge_commander, :send_emails_for_usage)
    |> send_email(usage, number, volume_used, allowance, name)
  end

  defp send_email(false, _usage, _number, _volume_used, _allowance, _name), do: Logger.info "Application is in dev mode."
  defp send_email(true, usage, number, volume_used, allowance, name) do
    EdgeCommander.EcMailer.usage_monitoring(usage, number, volume_used, allowance, name)
  end

  def list_rules do
    Repo.all(Rule)
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
end
