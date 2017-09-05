defmodule EdgeCommander.Devices.Nvr do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Devices.Nvr


  schema "nvrs" do
    field :extra, :map
    field :firmware_version, :string
    field :ip, :string
    field :is_monitoring, :boolean, default: false
    field :model, :string
    field :name, :string
    field :password, :string
    field :port, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%Nvr{} = nvr, attrs) do
    nvr
    |> cast(attrs, [:name, :ip, :port, :username, :password, :is_monitoring, :model, :firmware_version, :extra])
    |> validate_required([:name, :ip, :port, :username, :password, :is_monitoring])
  end
end
