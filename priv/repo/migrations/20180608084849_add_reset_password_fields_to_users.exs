defmodule EdgeCommander.Repo.Migrations.AddResetPasswordFieldsToUsers do
  use Ecto.Migration

  def change do
	alter table(:users) do
		add :reset_token, :string
		add :token_expire, :utc_datetime
	end
  end
end
