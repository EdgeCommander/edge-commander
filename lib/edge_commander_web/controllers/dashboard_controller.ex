defmodule EdgeCommanderWeb.DashboardController do
  use EdgeCommanderWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
