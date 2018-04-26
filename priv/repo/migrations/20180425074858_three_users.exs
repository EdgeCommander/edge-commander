defmodule EdgeCommander.Repo.Migrations.ThreeUsers do
  use Ecto.Migration

  def change do
	create table(:three_users) do
		add :username, :string
		add :password, :string
		add :user_id, references(:users)

		timestamps()
	end
  end
end
