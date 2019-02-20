defmodule EdgeCommander.Sharing do
  @moduledoc """
  The Sharing context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Sharing.Member
  alias EdgeCommander.Accounts.User

  @doc """
  Returns the list of sharing.

  ## Examples

      iex> list_sharing()
      [%Member{}, ...]

  """
  def list_sharing(user_id) do
    Member
    |> distinct([s], s.member_email)
    |> where(user_id: ^user_id)
    |> or_where(member_id: ^user_id)
    |> or_where(account_id: ^user_id)
    |> Repo.all
  end

  def all_shared_users(user_id) do
    query = from u in User,
      left_join: m in Member, on: u.id == m.account_id,
      where: m.member_id == ^user_id or u.id == ^user_id
    query
    |> Repo.all
  end

  @doc """
  Gets a single member.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123)
      %Member{}

      iex> get_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member!(id), do: Repo.get!(Member, id)

  def user_already_exist(member_email) do
    Member
    |> where(member_email: ^member_email)
    |> limit(1)
    |> Repo.one
  end

  def user_by_email(member_email) do
    Member
    |> where(member_email: ^member_email)
    |> Repo.all
  end

  def get_member_list(id) do
    Member
    |> where(member_id: ^id)
    |> or_where(account_id: ^id)
    |> Repo.all
  end

  def already_sharing(member_email, account_id) do
    Member
    |> where(member_email: ^member_email)
    |> where(account_id: ^account_id)
    |> Repo.one
  end

  def member_by_token(token) do
    member_id = 0
    Member
    |> where(token: ^token)
    |> where(member_id: ^member_id)
    |> limit(1)
    |> Repo.one
  end

  def member_by_account(member_id) do
    Member
    |> where(member_id: ^member_id)
    |> limit(1)
    |> Repo.one
  end

  def all_members_by_token(token) do
    Member
    |> where(token: ^token)
    |> Repo.all
  end

  def members_by_token_zero_account(token) do
    Member
    |> where(token: ^token)
    |> where(account_id: 0)
    |> Repo.all
  end

  @doc """
  Creates a member.

  ## Examples

      iex> create_member(%{field: value})
      {:ok, %Member{}}

      iex> create_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a member.

  ## Examples

      iex> update_member(member, %{field: new_value})
      {:ok, %Member{}}

      iex> update_member(member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Member.

  ## Examples

      iex> delete_member(member)
      {:ok, %Member{}}

      iex> delete_member(member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member(%Member{} = member) do
    Repo.delete(member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member changes.

  ## Examples

      iex> change_member(member)
      %Ecto.Changeset{source: %Member{}}

  """
  def change_member(%Member{} = member) do
    Member.changeset(member, %{})
  end
end
