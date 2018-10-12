defmodule EdgeCommander.Nexmo.SimMessages do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Nexmo.SimMessages


  schema "sms_messages" do
    field :from, :string
    field :message_id, :string
    field :status, :string
    field :text, :string
    field :to, :string
    field :type, :string
    field :user_id, :integer
    field :delivery_datetime, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(%SimMessages{} = sim_messages, attrs) do
    sim_messages
    |> cast(attrs, [:to, :from, :message_id, :status, :text, :type, :user_id, :delivery_datetime])
    |> validate_required([:to, :from, :message_id, :status, :text, :type, :user_id])
  end
end
