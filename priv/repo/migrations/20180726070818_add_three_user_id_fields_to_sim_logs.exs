defmodule EdgeCommander.Repo.Migrations.AddThreeUserIdFieldsToSimLogs do
  use Ecto.Migration

  def change do
	alter table(:sim_logs) do
		add :three_user_id, :integer
	end
  end
end
