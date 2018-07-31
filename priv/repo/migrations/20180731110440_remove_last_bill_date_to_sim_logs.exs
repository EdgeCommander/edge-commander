defmodule EdgeCommander.Repo.Migrations.RemoveLastBillDateToSimLogs do
  use Ecto.Migration

  def change do
	alter table(:sim_logs) do
		remove :last_bill_date
	end
  end
end
