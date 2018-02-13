defmodule EdgeCommander.Repo.Migrations.AddMoreFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :api_key, :string
      add :api_id, :string
    end

    create unique_index :users, [:email], name: :user_email_unique_index
    create unique_index :users, [:username], name: :user_username_unique_index
  end
end
