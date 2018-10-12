defmodule EdgeCommander.Repo.Migrations.AddDeliveryDatetimeToSmsMessages do
  use Ecto.Migration

  def change do
   	alter table(:sms_messages) do
      add :delivery_datetime, :naive_datetime
    end
   end
end