defmodule EdgeCommander.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Accounts.User


  schema "users" do

    field :firstname, :string
    field :lastname, :string
    field :email, :string
    field :username, :string
    field :password, :string
    field :password_confirmation, :string, virtual: true
    field :last_signed_in, :utc_datetime

    timestamps()
  end

  defp encrypt_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password, hash_password(password))
      _ ->
        changeset
    end
  end

  defp update_last_signed_in(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :last_signed_in, Ecto.DateTime.utc)
      _ ->
        changeset
    end
  end

  def hash_password(password) do
    Comeonin.Bcrypt.hashpass(password, Comeonin.Bcrypt.gen_salt(12, true))
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:firstname, :lastname, :username, :password, :email])
    |> validate_required([:firstname, :lastname, :username, :password, :email])
    |> unique_constraint(:username, [message: "Username has already been taken."])
    |> unique_constraint(:email, [message: "Email has already been taken."])
    |> validate_confirmation(:password, [message: "Passwords do not match"])
    |> encrypt_password
    |> update_last_signed_in
    |> update_change(:firstname, &String.trim/1)
    |> update_change(:lastname, &String.trim/1)
    |> validate_length(:firstname, [min: 3, message: "Firstname should be at least 2 character(s)."])
    |> validate_length(:lastname, [min: 3, message: "Lastname should be at least 2 character(s)."])
  end
end
