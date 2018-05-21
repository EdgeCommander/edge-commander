defmodule EdgeCommander.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo
  alias EdgeCommander.Accounts.User
  require Logger

  def login(params, repo) do
    user = repo.get_by(User, email: String.downcase(params["email"]))
    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _    -> :error
    end
  end

  def by_api_keys(api_id, api_key) do
    User
    |> where(api_id: ^api_id)
    |> where(api_key: ^api_key)
    |> Repo.one
  end

  def get_by_api_keys("", ""), do: nil
  def get_by_api_keys(nil, _api_key), do: nil
  def get_by_api_keys(_api_id, nil), do: nil
  def get_by_api_keys(api_id, api_key) do
    ConCache.dirty_get_or_store(:users, "#{api_id}_#{api_key}", fn() ->
      by_api_keys(api_id, api_key)
    end)
  end

  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> Comeonin.Bcrypt.checkpw(password, user.password)
    end
  end

  def current_user(conn) do
    conn = Plug.Conn.fetch_session(conn)
    id = Plug.Conn.get_session(conn, :current_user)
    if id, do: Repo.get(User, id)
  end

  def logged_in?(conn), do: !!current_user(conn)

  def update_last_login(params, repo) do
    user = repo.get_by(User, email: String.downcase(params["email"]))
    case user |> User.changeset(%{"last_signed_in" => Ecto.DateTime.utc }) |> Repo.insert_or_update do
      {:ok, _user} ->
        Logger.info "Last signed in updated!"
      {:error, _changeset} ->
        Logger.error "Last signed in not updated!"
    end
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
