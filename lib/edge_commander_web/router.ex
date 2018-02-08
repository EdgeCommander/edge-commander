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

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Edge Commander"
      },
      host: "localhost:4000"
    }
  end

  scope "/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :edge_commander,
      swagger_file: "swagger.json",
      disable_validator: true
  end

  scope "/", EdgeCommanderWeb do
    pipe_through :browser # Use the default browser stack

    get "/", RooterController, :sim_logs
    get "/nvrs", RooterController, :nvrs
    get "/routers", RooterController, :routers
    get "/commands", RooterController, :commands
    get "/sims/:sim_number", RooterController, :sim_graph_and_details
    get "/my_profile", RooterController, :my_profile
    get "/sites", RooterController, :sites
    get "/sms_messages", RooterController, :sms_messages
    get "/status_report", RooterController, :status_report

    get "/update_status_report", NvrsController, :update_status_report

    get "/users/sign_in", DashboardController, :sign_in
    get "/users/sign_up", DashboardController, :sign_up

    post "/users/sign_up", UsersController, :sign_up
    patch "/update_profile", UsersController, :update_profile

    post "/users/session", SessionController, :create
    get "/users/session", SessionController, :delete

  end

  # Other scopes may use custom stacks.
  scope "/v1", EdgeCommanderWeb do
    pipe_through :api

    get "/sim/data", SimsController, :get_sim_logs
    get "/sim/data/:sim_number", SimsController, :get_single_sim_data
    get "/chartjs/data", SimsController, :create_chartjs_line_data
    get "/sim/sms/:sim_number", SimsController, :get_single_sim_sms

    get "/routers", RoutersController, :get_all_routers
    post "/routers", RoutersController, :create
    patch "/routers/:router_id", RoutersController, :update
    delete "/routers/:router_id", RoutersController, :delete

    get "/nvrs", NvrsController, :get_all_nvrs
    post "/nvrs", NvrsController, :create
    delete "/nvrs/:nvr_id", NvrsController, :delete
    patch "/nvrs/:nvr_id", NvrsController, :update

    get "/sites", SitesController, :get_all_sites
    post "/sites/new", SitesController, :create
    patch "/sites/update", SitesController, :update
    delete "/sites/:site_id", SitesController, :delete

    get "/rules", CommandsController, :get_all_rules
    post "/rules/new", CommandsController, :create
    patch "/rules/update", CommandsController, :update
    delete "/rules/:rule_id", CommandsController, :delete

    patch "/update_profile", UsersController, :update_profile

    post "/send_sms", SimsController, :send_sms
    post "/receive_sms", SimsController, :receive_sms
    get "/delivery_receipt", SimsController, :delivery_receipt

    get "/get_all_sms/:from_date/:to_date", SmsController, :get_all_sms

  end
end