defmodule EdgeCommander.Monitors.NvrPorts do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Monitors.NvrPorts


  schema "nvr_ports" do
    field :done_at, :utc_datetime
    field :nvr_created_at, :utc_datetime
    field :extra, :map
    field :nvr_id, :integer
    field :nvr_user_id, :integer
    field :nvr_name, :string
    field :status, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(%NvrPorts{} = nvr_ports, attrs) do
    nvr_ports
    |> cast(attrs, [:nvr_id, :nvr_name, :done_at, :status, :extra, :nvr_created_at, :nvr_user_id])
    |> validate_required([:nvr_id, :nvr_name, :done_at, :status])
    |> unique_constraint(:nvr_id, name: :nvr_ports_nvr_id_done_at_index)
  end
end
