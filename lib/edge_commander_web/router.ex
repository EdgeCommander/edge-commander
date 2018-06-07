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

  pipeline :swagger_auth do
    plug EdgeCommanderWeb.AuthenticationPlug
  end

  pipeline :auth do
    plug EdgeCommander.Accounts.Pipeline
  end
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
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
      host: "app.edgecommander.com",
      tags: [
        %{
          name: "sims",
          description: "Everything about sims"
        },
        %{
          name: "nvrs",
          description: "Operations related to nvrs"
        },
        %{
          name: "sites",
          description: "Operations related to sites"
        },
        %{
          name: "rules",
          description: "Operations related to rules"
        },
        %{
          name: "routers",
          description: "Operations related to routers"
        }
      ]
    }
  end

  scope "/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :edge_commander,
      swagger_file: "swagger.json",
      disable_validator: true
  end

  # Maybe logged in scope
  scope "/", EdgeCommanderWeb do
    pipe_through [:browser, :auth]
    
    get "/", DashboardController, :sign_in
    post "/users/session", SessionController, :create
    get "/users/session", SessionController, :delete
    get "/users/sign_up", DashboardController, :sign_up
    post "/users/sign_up", UsersController, :sign_up
  end

  scope "/", EdgeCommanderWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/sims", RooterController, :sim_logs
    get "/nvrs", RooterController, :nvrs
    get "/routers", RooterController, :routers
    get "/commands", RooterController, :commands
    get "/sims/:sim_number", RooterController, :sim_graph_and_details
    get "/my_profile", RooterController, :my_profile
    get "/sites", RooterController, :sites
    get "/sms", RooterController, :sms_messages
    get "/status_report", RooterController, :status_report
    get "/api", RooterController, :swagger

    get "/sims/data/json", SimsController, :get_sim_logs
    get "/sims/data/:sim_number", SimsController, :get_single_sim_data
    get "/chartjs/data/:sim_number", SimsController, :create_chartjs_line_data
    get "/sims/sms/:sim_number", SimsController, :get_single_sim_sms
    post "/sims", SimsController, :create

    get "/routers/data", RoutersController, :get_all_routers
    post "/routers", RoutersController, :create
    patch "/routers/:id", RoutersController, :update
    delete "/routers/:id", RoutersController, :delete

    get "/nvrs/data", NvrsController, :get_all_nvrs
    post "/nvrs", NvrsController, :create
    delete "/nvrs/:id", NvrsController, :delete
    patch "/nvrs/:id", NvrsController, :update
    get "/nvrs/:id", NvrsController, :reboot

    get "/rules", CommandsController, :get_all_rules
    post "/rules/new", CommandsController, :create
    patch "/rules/update", CommandsController, :update
    delete "/rules/:id", CommandsController, :delete

    get "/sites/data", SitesController, :get_all_sites
    post "/sites/new", SitesController, :create
    patch "/sites/update", SitesController, :update
    delete "/sites/:id", SitesController, :delete

    get "/update_status_report", NvrsController, :update_status_report

    patch "/update_profile", UsersController, :update_profile

    post "/send_sms", SimsController, :send_sms
    post "/receive_sms", SimsController, :receive_sms
    get "/delivery_receipt", SimsController, :delivery_receipt
    get "/get_all_sms/:from_date/:to_date", SmsController, :get_all_sms

    get "/three_accounts", ThreeController, :get_all_three_accounts
    post "/three_accounts", ThreeController, :create
    patch "/three_accounts", ThreeController, :update
    delete "/three_accounts/:id", ThreeController, :delete

  end

  # Other scopes may use custom stacks.
  scope "/v1", EdgeCommanderWeb do
    pipe_through :api

    scope "/" do
      pipe_through :swagger_auth

      get "/sims", SimsController, :get_sim_logs
      get "/sims/:sim_number/usage", SimsController, :create_chartjs_line_data
      get "/sims/:sim_number", SimsController, :get_single_sim_data
      get "/sims/:sim_number/sms", SimsController, :get_single_sim_sms
      post "/sims", SimsController, :create

      get "/routers", RoutersController, :get_all_routers
      post "/routers", RoutersController, :create
      patch "/routers/:id", RoutersController, :update
      delete "/routers/:id", RoutersController, :delete

      get "/nvrs", NvrsController, :get_all_nvrs
      post "/nvrs", NvrsController, :create
      delete "/nvrs/:id", NvrsController, :delete
      patch "/nvrs/:id", NvrsController, :update

      get "/rules", CommandsController, :get_all_rules
      post "/rules/new", CommandsController, :create
      patch "/rules/update", CommandsController, :update
      delete "/rules/:id", CommandsController, :delete

      get "/sites", SitesController, :get_all_sites
      post "/sites/new", SitesController, :create
      patch "/sites/update", SitesController, :update
      delete "/sites/:id", SitesController, :delete

      patch "/update_profile", UsersController, :update_profile

      post "/sims/:sim_number/sms", SimsController, :send_sms
      post "/receive_sms", SimsController, :receive_sms
      get "/delivery_receipt", SimsController, :delivery_receipt

      get "/get_all_sms/:from_date/:to_date", SmsController, :get_all_sms
    end
  end
end
