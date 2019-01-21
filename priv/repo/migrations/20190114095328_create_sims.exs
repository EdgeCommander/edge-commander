defmodule EdgeCommander.Repo.Migrations.CreateSims do
  use Ecto.Migration

  def change do
  	create table(:sims) do
      add :number, :string
      add :name, :string
      add :addon, :string
      add :allowance, :string
      add :volume_used, :string
      add :sim_provider, :string
      add :yesterday_volume_used, :string
      add :percentage_used, :float
      add :remaning_days, :string
      add :last_log_reading_at, :naive_datetime
      add :last_bill_date, :string
      add :last_sms, :string
      add :last_sms_date, :string
      add :sms_since_last_bill, :integer
      add :status, :string
      add :user_id, :integer
      add :three_user_id, :integer

      timestamps()
    end
  end
end