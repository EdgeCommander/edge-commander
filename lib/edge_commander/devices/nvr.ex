defmodule EdgeCommander.Devices.Nvr do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Devices.Nvr
  require IEx

  @ip_regex ~r/^(http(s?):\/\/)?(((www\.)?+[a-zA-Z0-9\.\-\_]+(\.[a-zA-Z]{2,3})+)|(\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b))(\/[a-zA-Z0-9\_\-\s\.\/\?\%\#\&\=]*)?$/
  @valid_number ~r/^\d+$/

  schema "nvrs" do
    belongs_to :user, EdgeCommander.Accounts.User

    field :extra, :map
    field :firmware_version, :string
    field :ip, :string
    field :is_monitoring, :boolean, default: false
    field :model, :string
    field :name, :string
    field :password, :string
    field :port, :integer
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%Nvr{} = nvr, attrs) do
    nvr
    |> cast(attrs, [:name, :ip, :port, :username, :password, :is_monitoring, :model, :firmware_version, :extra, :user_id])
    |> validate_required(:name, [message: "Name cannot be empty."])
    |> validate_required(:ip, [message: "IP / URL cannot be empty."])
    |> validate_required(:port, [message: "Port cannot be empty."])
    |> validate_required(:username, [message: "Username cannot be empty."])
    |> validate_required(:password, [message: "Password cannot be empty."])
    |> validate_length(:name, [min: 3, message: "Name should be at least 2 character(s)."])
    |> validate_length(:username, [min: 3, message: "Username should be at least 2 character(s)."])
    |> validate_length(:password, [min: 3, message: "Password should be at least 2 character(s)."])
    |> validate_format(:ip, @ip_regex, [message: "URL / IP format isn't valid!"])
    |> validate_inclusion(:port, 1..65535, [message: "Port isn't valid!"])
  end
end
