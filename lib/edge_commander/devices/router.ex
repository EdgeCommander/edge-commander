defmodule EdgeCommander.Devices.Router do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Devices.Router

  @ip_regex ~r/^(http(s?):\/\/)?(((www\.)?+[a-zA-Z0-9\.\-\_]+(\.[a-zA-Z]{2,3})+)|(\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b))(\/[a-zA-Z0-9\_\-\s\.\/\?\%\#\&\=]*)?$/

  schema "routers" do
    belongs_to :user, EdgeCommander.Accounts.User

    field :extra, :map
    field :ip, :string
    field :is_monitoring, :boolean, default: false
    field :name, :string
    field :password, :string
    field :port, :integer
    field :router_status, :boolean, default: true
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%Router{} = router, attrs) do
    router
    |> cast(attrs, [:ip, :username, :password, :port, :extra, :name, :router_status, :is_monitoring, :user_id])
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
