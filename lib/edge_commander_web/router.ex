defmodule EdgeCommanderWeb.Router do
  use EdgeCommanderWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EdgeCommanderWeb do
    pipe_through :browser # Use the default browser stack

    get "/", RooterController, :index
    get "/sims", RooterController, :sim_logs

    get "/get_sims_data", SimsController, :get_sim_logs
    get "/create_morris_line_data", SimsController, :create_morris_line_data

    get "/users/sign_in", DashboardController, :sign_in
    get "/users/sign_up", DashboardController, :sign_up

    post "/users/sign_up", UsersController, :sign_up

    post "/users/session", SessionController, :create
    get "/users/session", SessionController, :delete

    post "/nvrs/new", NvrsController, :create
    get "/get_all_nvrs", NvrsController, :get_all_nvrs

    delete "/nvrs/delete", NvrsController, :delete
    patch "/nvrs/update", NvrsController, :update

    get "/update_status_report", NvrsController, :update_status_report
    get "/status_report", RooterController, :status_report
  end

  # Other scopes may use custom stacks.
  # scope "/api", EdgeCommanderWeb do
  #   pipe_through :api
  # end
end
