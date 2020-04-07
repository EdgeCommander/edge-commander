defmodule EdgeCommander.Redirection do
  import Plug.Conn

  def store_path_in_session(conn, _) do
    method = conn.method
    path = conn.request_path

    conn |> ensure_and_save(path, method)
  end

  defp ensure_and_save(conn, "/", _), do: conn
  defp ensure_and_save(conn, path, method) do
    case {method, storable?(path)} do
      {"GET", true} ->
         put_session(conn, :login_retargeting_path, path)
      {_, _} ->
        conn
    end
  end

  defp storable?(path) do
    !(path =~ "r/users/session/")
  end

end
