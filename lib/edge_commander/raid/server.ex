defmodule EdgeCommander.Raid.Server do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Raid.Server


  schema "servers" do
    field :ip, :string
    field :password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%Server{} = server, attrs) do
    server
    |> cast(attrs, [:ip, :username, :password])
    |> validate_required([:ip, :username, :password])
  end
end
