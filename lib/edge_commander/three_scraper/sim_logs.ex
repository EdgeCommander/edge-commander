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

    timestamps()
  end

  @doc false
  def changeset(%SimLogs{} = sim_logs, attrs) do
    sim_logs
    |> cast(attrs, [:number, :name, :addon, :allowance, :volume_used, :datatime])
    |> validate_required([:number, :name, :addon, :allowance, :volume_used, :datatime])
  end
end
