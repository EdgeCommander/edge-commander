defmodule EdgeCommanderWeb.RooterController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  import EdgeCommander.Accounts, only: [current_user: 1]
  import EdgeCommander.Devices, only: [list_nvrs: 0]

  def index(conn, _params) do
    with %User{} <- current_user(conn) do
      nvrs = list_nvrs()
      render(conn, "index.html", user: current_user(conn), nvrs: nvrs)
    else
      _ ->
        conn
        |> put_flash(:error, "You must be logged in to see that page :).")
        |> redirect(to: "/users/sign_in")
    end
  end
end
