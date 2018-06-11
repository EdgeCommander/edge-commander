defmodule EdgeCommander.Accounts.ErrorHandler do
  use EdgeCommanderWeb, :controller
  import Plug.Conn

  def auth_error(conn, {type, reason}, _opts) do
   body = to_string(type)
   conn
   |> put_resp_content_type("text/plain")
   |> redirect(to: "/")
  end
end