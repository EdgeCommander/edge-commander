defmodule EdgeCommander.Repo.Migrations.ModifySharingTable do
  use Ecto.Migration

  def change do
		alter table(:sharing) do
			remove :token
			remove :account_id
			remove :member_email
		end
		rename table(:sharing), :member_id, to: :sharee_id
		rename table(:sharing), :user_id, to: :sharer_id
		rename table(:sharing), :role, to: :rights
  end
end
