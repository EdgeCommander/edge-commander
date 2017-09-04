defmodule EdgeCommanderWeb.RooterController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Accounts.User
  import EdgeCommander.Accounts, only: [current_user: 1]

  def index(conn, _params) do
    with %User{} <- current_user(conn) do
      render conn, "index.html"
    else
      _ ->
        conn
        |> put_flash(:error, "You must be logged in to see that page :).")
        |> redirect(to: "/users/sign_in")
    end
  end
end
