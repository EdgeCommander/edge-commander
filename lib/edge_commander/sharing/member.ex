defmodule EdgeCommander.Sharing.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sharing" do
    field :sharee_id, :integer
    field :rights, :integer
    field :sharer_id, :integer

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:sharee_id, :sharer_id, :rights])
    |> validate_required(:sharee_id, [message: "sharee cannot be empty."])
    |> validate_required(:sharer_id, [message: "sharer cannot be empty."])
    |> validate_required(:rights, [message: "Rights cannot be empty."])
  end
end
