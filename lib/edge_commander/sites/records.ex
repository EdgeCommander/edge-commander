defmodule EdgeCommander.Sites.Records do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Sites.Records


  schema "sites" do
    field :location, :map
    field :name, :string
    field :notes, :string
    field :nvr_id, :integer
    field :router_id, :integer
    field :sim_number, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(%Records{} = records, attrs) do
    records
    |> cast(attrs, [:name, :location, :sim_number, :router_id, :nvr_id, :notes, :user_id])
    |> validate_required(:name, [message: "Name cannot be empty."])
  end
end
