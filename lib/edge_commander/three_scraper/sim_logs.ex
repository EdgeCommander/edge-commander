defmodule EdgeCommander.ThreeScraper.SimLogs do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.ThreeScraper.SimLogs


  schema "sim_logs" do
    field :addon, :string
    field :allowance, :string
    field :datetime, :naive_datetime
    field :name, :string
    field :number, :string
    field :volume_used, :string
    field :sim_provider, :string
    field :user_id, :integer

  end

  @doc false
  def changeset(%SimLogs{} = sim_logs, attrs) do
    sim_logs
    |> cast(attrs, [:number, :name, :addon, :allowance, :volume_used, :datetime, :sim_provider, :user_id])
    |> validate_required(:number, [message: "Number cannot be empty."])
    |> validate_required(:name, [message: "Name cannot be empty."])
    |> validate_required(:addon, [message: "Addon cannot be empty."])
    |> validate_required(:allowance, [message: "Allowance cannot be empty."])
    |> validate_required(:volume_used, [message: "Volume used cannot be empty."])
    |> validate_required(:sim_provider, [message: "Sim provider cannot be empty."])
    |> validate_required(:datetime, [message: "Datetime cannot be empty."])
  end
end
