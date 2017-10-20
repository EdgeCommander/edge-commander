defmodule EdgeCommander.Repo.Migrations.CreateRules do
  use Ecto.Migration

  def change do
    create table(:rules) do
      add :rule_name, :string
      add :category, :string
      add :recipients, {:array, :string}
      add :active, :boolean, default: true, null: false
      add :user_id, references(:users)

      timestamps()
    end

  end
end
