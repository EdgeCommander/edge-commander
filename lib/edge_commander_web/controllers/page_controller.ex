defmodule EdgeCommanderWeb.PageController do
  use EdgeCommanderWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
