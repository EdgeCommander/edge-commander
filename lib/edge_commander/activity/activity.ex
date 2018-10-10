defmodule EdgeCommander.Activity do
  @moduledoc """
  The Activity context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Activity.Logs

  @doc """
  Returns the list of logs.

  ## Examples

      iex> list_logs()
      [%Logs{}, ...]

  """
  def list_logs do
    Repo.all(Logs)
  end

  def get_list_logs(from_date, to_date, user_id) do
    from = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")
    Logs
    |> where([c],  c.user_id  == ^user_id and (c.inserted_at >= ^from or c.inserted_at == ^from))
    |> Repo.all
  end

  @doc """
  Gets a single logs.

  Raises `Ecto.NoResultsError` if the Logs does not exist.

  ## Examples

      iex> get_logs!(123)
      %Logs{}

      iex> get_logs!(456)
      ** (Ecto.NoResultsError)

  """
  def get_logs!(id), do: Repo.get!(Logs, id)

  @doc """
  Creates a logs.

  ## Examples

      iex> create_logs(%{field: value})
      {:ok, %Logs{}}

      iex> create_logs(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_logs(attrs \\ %{}) do
    %Logs{}
    |> Logs.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a logs.

  ## Examples

      iex> update_logs(logs, %{field: new_value})
      {:ok, %Logs{}}

      iex> update_logs(logs, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_logs(%Logs{} = logs, attrs) do
    logs
    |> Logs.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Logs.

  ## Examples

      iex> delete_logs(logs)
      {:ok, %Logs{}}

      iex> delete_logs(logs)
      {:error, %Ecto.Changeset{}}

  """
  def delete_logs(%Logs{} = logs) do
    Repo.delete(logs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking logs changes.

  ## Examples

      iex> change_logs(logs)
      %Ecto.Changeset{source: %Logs{}}

  """
  def change_logs(%Logs{} = logs) do
    Logs.changeset(logs, %{})
  end
end
