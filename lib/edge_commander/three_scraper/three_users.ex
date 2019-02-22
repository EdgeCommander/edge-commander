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
    field :bill_day, :integer

    timestamps()
  end

  def users_list do
    ThreeUsers
    |> Repo.all
  end

  def list_three_accounts() do
    ThreeUsers
    |>  Repo.all
  end

  def get_three_account!(id), do: Repo.get!(ThreeUsers, id)

  @doc false
  def changeset(%ThreeUsers{} = three_users, attrs) do
    three_users
    |> cast(attrs, [:username, :password, :user_id, :bill_day])
    |> validate_required(:username, [message: "Username cannot be empty."])
    |> validate_required(:password, [message: "Password cannot be empty."])
    |> validate_required(:bill_day, [message: "Bill day cannot be empty."])
  end

end
