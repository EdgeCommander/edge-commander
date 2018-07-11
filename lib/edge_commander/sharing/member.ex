defmodule EdgeCommander.Sharing.Member do
  use Ecto.Schema
  import Ecto.Changeset


  schema "sharing" do
    field :member_id, :integer
    field :role, :integer
    field :user_id, :integer
    field :member_email, :string

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:user_id, :member_id, :role, :member_email])
    |> validate_required(:member_email, [message: "Email cannot be empty."])
    |> validate_required(:role, [message: "Role cannot be empty."])
  end
end
