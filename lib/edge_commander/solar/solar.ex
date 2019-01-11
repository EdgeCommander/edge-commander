defmodule EdgeCommander.Solar do
  @moduledoc """
  The Solar context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Solar.Reading
  alias EdgeCommander.Solar.Battery

  @doc """
  Returns the list of reading.

  ## Examples

      iex> list_reading()
      [%Reading{}, ...]

  """

  def get_readings(from_date, to_date, battery_id) do
    from = from_date <> " 00:00:00"
    to = to_date <> " 23:59:59"
    query = from l in Reading,
      where: l.datetime >= ^from and l.datetime <= ^to and (l.battery_id == ^battery_id)
    query
    |> order_by(asc: :datetime)
    |> Repo.all
  end

  def get_maximum_voltage(date) do
    from = date <> " 00:00:00"
    to = date <> " 23:59:59"
    query = from l in Reading,
      where: l.datetime >= ^from and l.datetime <= ^to, select: max(l.voltage)
    query
    |> Repo.one
  end

  def get_minimum_voltage(date) do
    from = date <> " 00:00:00"
    to = date <> " 23:59:59"
    query = from l in Reading,
      where: l.datetime >= ^from and l.datetime <= ^to, select: min(l.voltage)
    query
    |> Repo.one
  end

  def list_reading do
    Repo.all(Reading)
  end

  @doc """
  Gets a single reading.

  Raises `Ecto.NoResultsError` if the reading does not exist.

  ## Examples

      iex> get_reading!(123)
      %Reading{}

      iex> get_reading!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reading!(id), do: Repo.get!(Reading, id)

  @doc """
  Creates a reading.

  ## Examples

      iex> create_reading(%{field: value})
      {:ok, %Reading{}}

      iex> create_reading(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reading(attrs \\ %{}) do
    %Reading{}
    |> Reading.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Reading.

  ## Examples

      iex> update_reading(Reading, %{field: new_value})
      {:ok, %Reading{}}

      iex> update_reading(Reading, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reading(%Reading{} = reading, attrs) do
    reading
    |> Reading.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Reading.

  ## Examples

      iex> delete_reading(reading)
      {:ok, %Reading{}}

      iex> delete_reading(reading)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reading(%Reading{} = reading) do
    Repo.delete(reading)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reading changes.

  ## Examples

      iex> change_reading(reading)
      %Ecto.Changeset{source: %Reading{}}

  """
  def change_reading(%Reading{} = reading) do
    Reading.changeset(reading, %{})
  end

  ##----------------------batteries-----------------------

  def list_batteries(user_id) do
    Battery
    |> where([c],  c.user_id  == ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all
  end

  def list_active_batteries() do
    Battery
    |> where(active: true)
    |> Repo.all
  end

  @doc """
  Gets a single battery.

  Raises `Ecto.NoResultsError` if the battery does not exist.

  ## Examples

      iex> get_battery!(123)
      %Reading{}

      iex> get_battery!(456)
      ** (Ecto.NoResultsError)

  """
  def get_battery!(id), do: Repo.get!(Battery, id)

  @doc """
  Creates a battery.

  ## Examples

      iex> create_battery(%{field: value})
      {:ok, %Reading{}}

      iex> create_battery(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_battery(attrs \\ %{}) do
    %Battery{}
    |> Battery.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Battery.

  ## Examples

      iex> update_battery(Battery, %{field: new_value})
      {:ok, %Reading{}}

      iex> update_battery(Battery, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_battery(%Battery{} = battery, attrs) do
    battery
    |> Reading.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a battery.

  ## Examples

      iex> delete_battery(battery)
      {:ok, %Reading{}}

      iex> delete_battery(battery)
      {:error, %Ecto.Changeset{}}

  """
  def delete_battery(%Battery{} = battery) do
    Repo.delete(battery)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reading changes.

  ## Examples

      iex> change_battery(battery)
      %Ecto.Changeset{source: %Battery{}}

  """
  def change_battery(%Battery{} = battery) do
    Reading.changeset(battery, %{})
  end
end
