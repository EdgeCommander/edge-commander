defmodule EdgeCommander.Solar do
  @moduledoc """
  The Solar context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Solar.Battery

  @doc """
  Returns the list of battery.

  ## Examples

      iex> list_battery()
      [%Battery{}, ...]

  """
  def list_battery do
    Repo.all(Battery)
  end

  @doc """
  Gets a single battery.

  Raises `Ecto.NoResultsError` if the Battery does not exist.

  ## Examples

      iex> get_battery!(123)
      %Battery{}

      iex> get_battery!(456)
      ** (Ecto.NoResultsError)

  """
  def get_battery!(id), do: Repo.get!(Battery, id)

  @doc """
  Creates a battery.

  ## Examples

      iex> create_battery(%{field: value})
      {:ok, %Battery{}}

      iex> create_battery(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_battery(attrs \\ %{}) do
    %Battery{}
    |> Battery.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a battery.

  ## Examples

      iex> update_battery(battery, %{field: new_value})
      {:ok, %Battery{}}

      iex> update_battery(battery, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_battery(%Battery{} = battery, attrs) do
    battery
    |> Battery.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Battery.

  ## Examples

      iex> delete_battery(battery)
      {:ok, %Battery{}}

      iex> delete_battery(battery)
      {:error, %Ecto.Changeset{}}

  """
  def delete_battery(%Battery{} = battery) do
    Repo.delete(battery)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking battery changes.

  ## Examples

      iex> change_battery(battery)
      %Ecto.Changeset{source: %Battery{}}

  """
  def change_battery(%Battery{} = battery) do
    Battery.changeset(battery, %{})
  end
end
