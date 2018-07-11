defmodule EdgeCommander.Repo.Migrations.CreateSharing do
  use Ecto.Migration

  def change do
    create table(:sharing) do
      add :user_id, references(:users)
      add :member_id, :integer
      add :member_email, :string
      add :role, :integer

      timestamps()
    end

  end
end
