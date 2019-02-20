defmodule EdgeCommander.ThreeScraper.ThreeUsers do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias EdgeCommander.ThreeScraper.ThreeUsers
  alias EdgeCommander.Repo
  alias EdgeCommander.Sharing.Member

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

  def list_three_accounts(user_id) do
    query = from u in ThreeUsers,
      left_join: m in Member, on: u.user_id == m.account_id,
      where: (m.member_id == ^user_id or u.user_id == ^user_id),
      distinct: u.id,
      select: %{
          id: u.id,
          username: u.username,
          password: u.password,
          user_id: u.user_id,
          bill_day: u.bill_day,
          inserted_at: u.inserted_at
        }
    query
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
