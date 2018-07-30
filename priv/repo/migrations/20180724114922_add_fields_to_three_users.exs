defmodule EdgeCommander.Repo.Migrations.AddFieldsToThreeUsers do
  use Ecto.Migration

  def change do
	alter table(:three_users) do
		add :bill_day, :integer
	end
  end
end
