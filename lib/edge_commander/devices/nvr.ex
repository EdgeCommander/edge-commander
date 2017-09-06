defmodule EdgeCommander.Devices.Nvr do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Devices.Nvr

  @ip_regex ~r/^(http(s?):\/\/)?(((www\.)?+[a-zA-Z0-9\.\-\_]+(\.[a-zA-Z]{2,3})+)|(\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b))(\/[a-zA-Z0-9\_\-\s\.\/\?\%\#\&\=]*)?$/

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

  defp _check_port(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{port: port}} ->
        test_port_or_add_error(changeset, port)
      _ ->
        changeset
    end
  end

  defp test_port_or_add_error(changeset, port) do
    case Integer.parse(port) do
      {_number, ""} -> put_change(changeset, :port, port)
      _ -> add_error(changeset, :port, "Please enter an integer value.")
    end
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
  end
end
