defmodule TwimaWeb.Router do
  use TwimaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TwimaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TwimaWeb.Plugs.LoginRedirect
  end

  pipeline :api_auth do
    plug TwimaWeb.Plugs.ApiAuth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/", TwimaWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/choose", PageController, :choose
  end

  scope "/api", TwimaWeb do
    pipe_through :api

    post "/register_app", ApiController, :register_app
    get "/consume", ApiController, :consume

    scope "/" do
      pipe_through :api_auth

      post "/post", ApiController, :post_status
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:twima, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TwimaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
