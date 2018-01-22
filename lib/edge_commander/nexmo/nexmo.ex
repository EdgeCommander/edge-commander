defmodule EdgeCommander.Nexmo do
  @moduledoc """
  The Nexmo context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Nexmo.SimMessages
  require IEx

  @doc """
  Returns the list of sms_messages.

  ## Examples

      iex> list_sms_messages()
      [%SimMessages{}, ...]

  """
  def list_sms_messages(from_date, to_date) do
    from = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")
    SimMessages
    |> where([c], c.inserted_at >= ^from and c.inserted_at <= ^to)
    |> Repo.all
  end

  @doc """
  Gets a single sim_messages.

  Raises `Ecto.NoResultsError` if the Sim messages does not exist.

  ## Examples

      iex> get_sim_messages!(123)
      %SimMessages{}

      iex> get_sim_messages!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sim_messages!(id), do: Repo.get!(SimMessages, id)

  def get_message(message_id) do
    SimMessages
    |> where(message_id: ^message_id)
    |> Repo.one
  end

  def get_single_sim_messages(number) do
    SimMessages
    |> where(from: ^number)
    |> or_where(to: ^number)
    |> order_by(desc: :inserted_at)
    |> limit(10)
    |> Repo.all
  end

  @doc """
  Creates a sim_messages.

  ## Examples

      iex> create_sim_messages(%{field: value})
      {:ok, %SimMessages{}}

      iex> create_sim_messages(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sim_messages(attrs \\ %{}) do
    %SimMessages{}
    |> SimMessages.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sim_messages.

  ## Examples

      iex> update_sim_messages(sim_messages, %{field: new_value})
      {:ok, %SimMessages{}}

      iex> update_sim_messages(sim_messages, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sim_messages(%SimMessages{} = sim_messages, attrs) do
    sim_messages
    |> SimMessages.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SimMessages.

  ## Examples

      iex> delete_sim_messages(sim_messages)
      {:ok, %SimMessages{}}

      iex> delete_sim_messages(sim_messages)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sim_messages(%SimMessages{} = sim_messages) do
    Repo.delete(sim_messages)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sim_messages changes.

  ## Examples

      iex> change_sim_messages(sim_messages)
      %Ecto.Changeset{source: %SimMessages{}}

  """
  def change_sim_messages(%SimMessages{} = sim_messages) do
    SimMessages.changeset(sim_messages, %{})
  end
end
