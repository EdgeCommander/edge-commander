defmodule EdgeCommander.Repo.Migrations.AddMoreFieldsToRules do
  use Ecto.Migration

  def change do
	alter table(:rules) do
		add :variable, :string
		add :value, :integer
	end
  end
end
