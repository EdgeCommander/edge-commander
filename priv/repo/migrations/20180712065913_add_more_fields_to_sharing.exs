defmodule EdgeCommander.Repo.Migrations.AddMoreFieldsToSharing do
   use Ecto.Migration
   def change do
   	alter table(:sharing) do
      add :token, :string
      add :account_of_id, :integer
    end
   end
end