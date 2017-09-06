defmodule EdgeCommander.Devices do
  @moduledoc """
  The Devices context.
  """

  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Devices.Nvr

  @doc """
  Returns the list of nvrs.

  ## Examples

      iex> list_nvrs()
      [%Nvr{}, ...]

  """
  def list_nvrs do
    Repo.all(Nvr)
  end

  @doc """
  Gets a single nvr.

  Raises `Ecto.NoResultsError` if the Nvr does not exist.

  ## Examples

      iex> get_nvr!(123)
      %Nvr{}

      iex> get_nvr!(456)
      ** (Ecto.NoResultsError)

  """
  def get_nvr!(id), do: Repo.get!(Nvr, id)

  @doc """
  Creates a nvr.

  ## Examples

      iex> create_nvr(%{field: value})
      {:ok, %Nvr{}}

      iex> create_nvr(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_nvr(attrs \\ %{}) do
    %Nvr{}
    |> Nvr.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a nvr.

  ## Examples

      iex> update_nvr(nvr, %{field: new_value})
      {:ok, %Nvr{}}

      iex> update_nvr(nvr, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_nvr(%Nvr{} = nvr, attrs) do
    nvr
    |> Nvr.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Nvr.

  ## Examples

      iex> delete_nvr(nvr)
      {:ok, %Nvr{}}

      iex> delete_nvr(nvr)
      {:error, %Ecto.Changeset{}}

  """
  def delete_nvr(%Nvr{} = nvr) do
    Repo.delete(nvr)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking nvr changes.

  ## Examples

      iex> change_nvr(nvr)
      %Ecto.Changeset{source: %Nvr{}}

  """
  def change_nvr(%Nvr{} = nvr) do
    Nvr.changeset(nvr, %{})
  end
end
