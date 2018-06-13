defmodule EdgeCommander.Repo.Migrations.AddBillDateFieldToSimLogs do
  use Ecto.Migration

  def change do
	alter table(:sim_logs) do
      add :last_bill_date, :naive_datetime
    end
  end
end
