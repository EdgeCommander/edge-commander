defmodule EdgeCommander.ThreeScraper.Sims do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.ThreeScraper.Sims


  schema "sims" do
    field :number, :string
    field :name, :string
    field :addon, :string
    field :allowance, :string
    field :volume_used, :string
    field :sim_provider, :string
    field :yesterday_volume_used, :string
    field :percentage_used, :float
    field :remaning_days, :string
    field :last_log_reading_at, :naive_datetime
    field :last_bill_date, :string
    field :last_sms, :string
    field :last_sms_date, :string
    field :sms_since_last_bill, :integer
    field :status, :string
    field :user_id, :integer
    field :three_user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(%Sims{} = sims, attrs) do
    sims
    |> cast(attrs, [:number, :name, :addon, :allowance, :volume_used, :sim_provider, :yesterday_volume_used, :percentage_used, :remaning_days, :last_log_reading_at, :last_bill_date, :last_sms, :last_sms_date, :sms_since_last_bill, :status, :user_id, :three_user_id])
    |> validate_required([:number, :name, :addon, :allowance, :volume_used, :sim_provider, :yesterday_volume_used, :percentage_used, :remaning_days, :last_log_reading_at, :last_bill_date, :last_sms, :last_sms_date, :sms_since_last_bill, :status, :user_id, :three_user_id])
  end
end
