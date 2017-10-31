defmodule EdgeCommander.Raid do
  @moduledoc """
  The Raid context.
  """
  require IEx
  require Logger
  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Raid.Server

  @failed_drive_command "/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -aALL | grep 'Failed'"

  def check_failed_drives do
    list_servers()
    |> Enum.map(fn(server) ->
      go_through_and_email(server)
    end)
  end

  defp get_conn_for_server({:error, :timeout}, server), do: go_through_and_email(server)
  defp get_conn_for_server({:ok, conn}, server) do
    run_command_on_server(conn)
    |> command_results(server)
  end

  defp command_results({:error, reason}, _server), do: Logger.info reason
  defp command_results({:ok, res, 0}, server) do
    String.match?(res, ~r/1/)
    |> is_that_a_failure(res, server)
  end

  defp is_that_a_failure(false, _res, server), do: Logger.info "RAID is fine on #{server.ip}."
  defp is_that_a_failure(true, res, server), do:
    EdgeCommander.EcMailer.send_email_for_raid(res, server)

  defp go_through_and_email(server) do
    connect_to_server(server)
    |> get_conn_for_server(server)
  end

  defp connect_to_server(server), do:
    SSHEx.connect(ip: server.ip, user: server.username, password: server.password)

  defp run_command_on_server(conn, command \\ @failed_drive_command), do:
    SSHEx.run(conn, command)

  @doc """
  Returns the list of servers.

  ## Examples

      iex> list_servers()
      [%Server{}, ...]

  """
  def list_servers do
    Repo.all(Server)
  end

  @doc """
  Gets a single server.

  Raises `Ecto.NoResultsError` if the Server does not exist.

  ## Examples

      iex> get_server!(123)
      %Server{}

      iex> get_server!(456)
      ** (Ecto.NoResultsError)

  """
  def get_server!(id), do: Repo.get!(Server, id)

  @doc """
  Creates a server.

  ## Examples

      iex> create_server(%{field: value})
      {:ok, %Server{}}

      iex> create_server(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_server(attrs \\ %{}) do
    %Server{}
    |> Server.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server.

  ## Examples

      iex> update_server(server, %{field: new_value})
      {:ok, %Server{}}

      iex> update_server(server, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_server(%Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Server.

  ## Examples

      iex> delete_server(server)
      {:ok, %Server{}}

      iex> delete_server(server)
      {:error, %Ecto.Changeset{}}

  """
  def delete_server(%Server{} = server) do
    Repo.delete(server)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server changes.

  ## Examples

      iex> change_server(server)
      %Ecto.Changeset{source: %Server{}}

  """
  def change_server(%Server{} = server) do
    Server.changeset(server, %{})
  end
end
