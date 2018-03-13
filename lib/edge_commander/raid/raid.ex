defmodule EdgeCommander.Raid do
  @moduledoc """
  The Raid context.
  """
  require IEx
  require Logger
  import Ecto.Query, warn: false
  alias EdgeCommander.Repo

  alias EdgeCommander.Raid.Server

  @failed_drive_command_raid "/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -aALL | grep 'Failed'"
  @check_which_raid "lspci | grep -i raid"
  @failed_drive_command_adaptec "/tmp/arcconf getconfig 1 | grep 'Degraded'"

  def check_failed_drives do
    list_servers()
    |> Enum.map(fn(server) ->
      go_through_and_email(server)
    end)
  end

  defp get_conn_for_server({:error, :timeout}, server), do: go_through_and_email(server)
  defp get_conn_for_server({:ok, conn}, server) do
    run_command_on_server(@check_which_raid, conn)
    |> select_command_for_raid()
    |> run_command_on_server(conn)
    |> command_results(server)
  end

  defp select_command_for_raid({:error, _reason}), do: :noop
  defp select_command_for_raid({:ok, res, 0}) do
    case String.match?(res, ~r/MegaRAID/) do
      true -> @failed_drive_command_raid
      _ -> @failed_drive_command_adaptec
    end
  end

  defp command_results({:error, reason}, _server), do: Logger.info reason
  defp command_results({:ok, res, 0}, server) do
    EdgeCommander.EcMailer.send_email_for_raid(res, server)
  end

  defp go_through_and_email(server) do
    connect_to_server(server)
    |> get_conn_for_server(server)
  end

  defp connect_to_server(server), do:
    SSHEx.connect(ip: server.ip, user: server.username, password: server.password)

  defp run_command_on_server(command, conn), do:
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
