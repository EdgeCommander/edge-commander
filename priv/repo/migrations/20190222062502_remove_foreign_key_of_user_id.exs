defmodule EdgeCommander.Repo.Migrations.RemoveForeignKeyOfUserId do
  use Ecto.Migration

  def change do
  	drop constraint(:logs, "logs_user_id_fkey")
  	drop constraint(:batteries, "batteries_user_id_fkey")
  	drop constraint(:nvrs, "nvrs_user_id_fkey")
  	drop constraint(:routers, "routers_user_id_fkey")
  	drop constraint(:rules, "rules_user_id_fkey")
  	drop constraint(:sharing, "sharing_user_id_fkey")
  	drop constraint(:sim_logs, "sim_logs_user_id_fkey")
  	drop constraint(:sites, "sites_user_id_fkey")
  	drop constraint(:three_users, "three_users_user_id_fkey")
  end
end
