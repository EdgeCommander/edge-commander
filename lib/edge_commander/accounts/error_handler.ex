defmodule EdgeCommander.Accounts.ErrorHandler do
  use EdgeCommanderWeb, :controller
  import Plug.Conn

  def auth_error(conn, {_type, _reason}, _opts) do
   conn
   |> put_resp_content_type("text/plain")
   |> redirect(to: "/")
  end
end