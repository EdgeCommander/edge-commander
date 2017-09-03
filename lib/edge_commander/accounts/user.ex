defmodule EdgeCommander.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Accounts.User


  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
  end
end
