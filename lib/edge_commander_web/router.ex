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

    get "/", RooterController, :sim_logs
    get "/nvrs", RooterController, :nvrs
    get "/routers", RooterController, :routers
    get "/commands", RooterController, :commands
    get "/sims/:sim_number", RooterController, :sim_graph_and_details
    get "/my_profile", RooterController, :get_my_profile

    get "/get_sims_data", SimsController, :get_sim_logs
    get "/get_single_sim_data/:sim_number", SimsController, :get_single_sim_data
    get "/create_chartjs_line_data", SimsController, :create_chartjs_line_data

    get "/users/sign_in", DashboardController, :sign_in
    get "/users/sign_up", DashboardController, :sign_up

    post "/users/sign_up", UsersController, :sign_up
    patch "/update_profile", UsersController, :update_profile

    post "/users/session", SessionController, :create
    get "/users/session", SessionController, :delete

    get "/get_all_routers", RoutersController, :get_all_routers
    post "/routers/new", RoutersController, :create
    patch "/routers/update", RoutersController, :update
    delete "/routers/delete", RoutersController, :delete

    post "/nvrs/new", NvrsController, :create
    get "/get_all_nvrs", NvrsController, :get_all_nvrs

    delete "/nvrs/delete", NvrsController, :delete
    patch "/nvrs/update", NvrsController, :update

    get "/update_status_report", NvrsController, :update_status_report
    get "/status_report", RooterController, :status_report

    get "/get_all_rules", CommandsController, :get_all_rules
    post "/rules/new", CommandsController, :create
    patch "/rules/update", CommandsController, :update
    delete "/rules/delete", CommandsController, :delete
    
    post "/send_sms", SimsController, :send_sms

  end

  # Other scopes may use custom stacks.
  # scope "/api", EdgeCommanderWeb do
  #   pipe_through :api
  # end
end