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
    field :api_key, :string
    field :api_id, :string
    field :password_confirmation, :string, virtual: true
    field :last_signed_in, :utc_datetime
    field :reset_token, :string
    field :token_expire, :utc_datetime

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
    utc_datetime = Calendar.DateTime.now_utc |> DateTime.truncate(:second)
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :last_signed_in, utc_datetime)
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
    |> cast(attrs, [:firstname, :lastname, :username, :password, :email, :api_id, :api_key, :reset_token, :token_expire])
    |> validate_required(:firstname, [message: "Firstname cannot be empty."])
    |> validate_required(:lastname, [message: "Lastname cannot be empty."])
    |> validate_required(:password, [message: "Password cannot be empty."])
    |> validate_required(:email, [message: "Email cannot be empty."])
    |> validate_required(:username)
    |> unique_constraint(:username, [name: :user_username_unique_index, message: "Username has already been taken."])
    |> unique_constraint(:email, [name: :user_email_unique_index, message: "Email has already been taken."])
    |> validate_confirmation(:password, [message: "Passwords do not match"])
    |> encrypt_password
    |> update_last_signed_in
    |> update_change(:firstname, &String.trim/1)
    |> update_change(:lastname, &String.trim/1)
    |> validate_length(:firstname, [min: 3, message: "Firstname should be at least 2 character(s)."])
    |> validate_length(:lastname, [min: 3, message: "Lastname should be at least 2 character(s)."])
  end
end