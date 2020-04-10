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
    plug :store_path_in_session
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
        },
        %{
          name: "batteries",
          description: "Operations related to batteries"
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
    post "/users/sign_up", UsersController, :sign_up
    get "/users/forgot_password", DashboardController, :forgot_password
    get "/users/reset_password/:token", DashboardController, :reset_password
    post "/users/forgot_password", UsersController, :forgot_password
    post "/users/reset_password", UsersController, :reset_password
    get "/receive_sms", SimsController, :receive_sms
    get "/delivery_receipt", SimsController, :delivery_receipt
    get "/users/reset_password_success", DashboardController, :reset_password_success
  end

  scope "/", EdgeCommanderWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/get_porfile", UsersController, :get_porfile
    get "/about", RooterController, :main
    get "/sims", RooterController, :main
    get "/nvrs", RooterController, :main
    get "/routers", RooterController, :main
    get "/commands", RooterController, :main
    get "/sims/:sim_number", RooterController, :main
    get "/sites", RooterController, :main
    get "/messages", RooterController, :main
    get "/messages/:number", RooterController, :main
    get "/status_report", RooterController, :main
    get "/api", RooterController, :main
    get "/shares", RooterController, :main
    get "/dashboard", RooterController, :main
    get "/battery/:id", RooterController, :main
    get "/batteries", RooterController, :main
    get "/my_profile", RooterController, :main
    get "/three_users", RooterController, :main
    get "/activities", RooterController, :main
    get "/sharing", RooterController, :main

    post "/sims", SimsController, :create
    patch "/sims/:id", SimsController, :update
    delete "/sims/:id", SimsController, :delete_sim
    get "/all_sim", SimsController, :get_all_sims

    get "/sims/data/json", SimsController, :get_sims_list
    get "/sims/sms/:sim_number", SimsController, :get_single_sim_sms
    post "/messages", SimsController, :create
    get "/user_logs", LogsController, :get_user_logs
    get "/sims/:sim_number/json", SimsController, :get_single_sim_data

    get "/routers/data", RoutersController, :get_all_routers
    post "/routers", RoutersController, :create
    patch "/routers/:id", RoutersController, :update
    delete "/routers/:id", RoutersController, :delete_router
    get "/all_routers", RoutersController, :get_all

    get "/nvrs/data", NvrsController, :get_all_nvrs
    post "/nvrs", NvrsController, :create
    delete "/nvrs/:id", NvrsController, :delete_nvr
    patch "/nvrs/:id", NvrsController, :update
    get "/nvrs/:id", NvrsController, :reboot
    get "/all_nvrs", NvrsController, :get_all

    get "/members", SharingController, :get_all_members
    post "/members/new", SharingController, :create
    delete "/members/:id", SharingController, :delete

    get "/rules", CommandsController, :get_all_rules
    post "/rules/new", CommandsController, :create
    patch "/rules/update", CommandsController, :update
    delete "/rules/:id", CommandsController, :delete_rule

    get "/sites/data", SitesController, :get_all_sites
    post "/sites/new", SitesController, :create
    patch "/sites/update", SitesController, :update
    delete "/sites/:id", SitesController, :delete_site

    get "/update_status_report", NvrsController, :update_status_report

    patch "/update_profile", UsersController, :update_profile

    post "/send_sms", SimsController, :send_sms
    get "/get_all_sms", SmsController, :get_all_sms
    get "/daily_sms_count/:number", SimsController, :daily_sms_count

    get "/dashboard/total_sims", DashboardController, :total_sims
    get "/dashboard/total_nvrs", DashboardController, :total_nvrs
    get "/dashboard/total_routers", DashboardController, :total_routers
    get "/dashboard/total_sites", DashboardController, :total_sites
    get "/dashboard/weekly_sms_overview", DashboardController, :weekly_sms_overview

    get "/batteries/data", BatteryController, :get_all_batteries
    post "/batteries/new", BatteryController, :create
    patch "/batteries/:id", BatteryController, :update
    delete "/batteries/:id", BatteryController, :delete_battery
    get "/batteries/:id", BatteryController, :get_single_battery

    get "/batteries/:id/readings", BatteryReadingController, :get_battery_record
    get "/batteries/:id/readings/voltages", DashboardController, :daily_battery_voltages
    get "/batteries/:id/readings/voltages/comparison", DashboardController, :battery_voltages_summary

  end

  # Other scopes may use custom stacks.
  scope "/v1", EdgeCommanderWeb do
    pipe_through :api

    scope "/" do
      pipe_through :swagger_auth

      post "/batteries", BatteryController, :create

      get "/sims", SimsController, :get_all_sims_by_users
      get "/sims/:sim_number/sms", SimsController, :get_single_sim_sms
      post "/sims", SimsController, :create
      get "/sims/:sim_number", SimsController, :get_single_sim_data

      get "/routers", RoutersController, :get_all_routers_by_users
      post "/routers", RoutersController, :create
      patch "/routers/:id", RoutersController, :update
      delete "/routers/:id", RoutersController, :delete_router

      get "/nvrs", NvrsController, :get_all_nvrs_by_users
      post "/nvrs", NvrsController, :create
      delete "/nvrs/:id", NvrsController, :delete_nvr
      patch "/nvrs/:id", NvrsController, :update

      get "/rules", CommandsController, :get_all_rules_by_users
      post "/rules/new", CommandsController, :create
      patch "/rules/update", CommandsController, :update
      delete "/rules/:id", CommandsController, :delete_rule

      get "/sites", SitesController, :get_all_sites_by_users
      post "/sites/new", SitesController, :create
      patch "/sites/update", SitesController, :update
      delete "/sites/:id", SitesController, :delete_site

      patch "/update_profile", UsersController, :update_profile

      post "/sims/:sim_number/sms", SimsController, :send_sms
      get "/receive_sms", SimsController, :receive_sms
      get "/delivery_receipt", SimsController, :delivery_receipt
      get "/daily_sms_count/:number", SimsController, :daily_sms_count

      get "/get_all_sms/:from_date/:to_date", SmsController, :get_all_sms

      post "/batteries/new", BatteryController, :create
      get "/batteries", BatteryController, :get_all_batteries_by_users
      delete "/batteries/:id", BatteryController, :delete_battery
      patch "/batteries/:id", BatteryController, :update
      get "/batteries/:id", BatteryController, :get_single_battery

      get "/batteries/:id/readings", BatteryReadingController, :get_all_readings_by_battery

    end
  end
end
