defmodule EdgeCommander.ThreeScraper.ThreeUsers do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias EdgeCommander.ThreeScraper.ThreeUsers
  alias EdgeCommander.Repo

  schema "three_users" do
    field :username, :string
    field :password, :string
    field :user_id, :integer

    timestamps()
  end

   def list_three_users do
    ThreeUsers
    |> Repo.all
  end

  def list_three_accounts(user_id) do
    ThreeUsers
    |> where(user_id: ^user_id)
    |> Repo.all
  end

  def get_three_account!(id), do: Repo.get!(ThreeUsers, id)

  @doc false
  def changeset(%ThreeUsers{} = three_users, attrs) do
    three_users
    |> cast(attrs, [:username, :password, :user_id])
    |> validate_required(:username, [message: "Username cannot be empty."])
    |> validate_required(:password, [message: "Password cannot be empty."])
  end

end
