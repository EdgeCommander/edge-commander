defmodule EdgeCommander.Activity.Logs do
  use Ecto.Schema
  import Ecto.Changeset


  schema "logs" do
    field :browser, :string
    field :country, :string
    field :country_code, :string
    field :event, :string
    field :ip, :string
    field :platform, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(logs, attrs) do
    logs
    |> cast(attrs, [:browser, :platform, :country, :country_code, :event, :ip, :user_id])
    |> validate_required([:browser, :platform, :event, :ip])
  end
end


