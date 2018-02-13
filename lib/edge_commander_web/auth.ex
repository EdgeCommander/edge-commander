defmodule EdgeCommanderWeb.Auth do
  alias EdgeCommander.Accounts

  def validate("", ""), do: :invalid
  def validate(api_id, api_key) do
    cond do
      user = Accounts.get_by_api_keys(api_id, api_key) -> {:valid, user}
      true -> :invalid
    end
  end
end
