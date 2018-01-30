defmodule EdgeCommanderWeb.Router do
  use EdgeCommanderWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :csrf do
    plug :protect_from_forgery
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
    get "/my_profile", RooterController, :my_profile

    get "/get_sims_data", SimsController, :get_sim_logs
    get "/get_single_sim_data/:sim_number", SimsController, :get_single_sim_data
    get "/create_chartjs_line_data", SimsController, :create_chartjs_line_data
    get "/get_single_sim_sms/:sim_number", SimsController, :get_single_sim_sms

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
    post "/receive_sms", SimsController, :receive_sms
    get "/delivery_receipt", SimsController, :delivery_receipt

    get "/sites", RooterController, :sites
    get "/get_all_sites", SitesController, :get_all_sites
    post "/sites/new", SitesController, :create
    patch "/sites/update", SitesController, :update
    delete "/sites/delete", SitesController, :delete

    get "/sms_messages", RooterController, :sms_messages
    get "/get_all_sms/:from_date/:to_date", SmsController, :get_all_sms

  end

  # Other scopes may use custom stacks.
  # scope "/api", EdgeCommanderWeb do
  #   pipe_through :api
  # end
end