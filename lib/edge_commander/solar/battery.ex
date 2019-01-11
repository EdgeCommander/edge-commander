defmodule EdgeCommander.Solar.Battery do
  use Ecto.Schema
  import Ecto.Changeset


  schema "batteries" do
    field :name, :string
    field :source_url, :string
    field :user_id, :integer
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(battery, attrs) do
    battery
    |> cast(attrs, [:name, :source_url, :user_id, :active])
    |> validate_required(:name, [message: "Name cannot be empty."])
    |> validate_required(:source_url, [message: "URL cannot be empty."])
  end
end
