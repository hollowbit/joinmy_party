defmodule JoinmyPartyWeb.Router do
  use JoinmyPartyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {JoinmyPartyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Enables LiveDashboard only for development
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: JoinmyPartyWeb.Telemetry
    end
  end

  # Enables HTML/CSS testing pages for development
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      live "/tester", JoinmyPartyWeb.LiveTester
    end
  end


  # Game routes go after test & dev routes to avoid overriding them
  scope "/", JoinmyPartyWeb do
    pipe_through :browser

    live "/", IndexWebLive, :index

    live "/:room_id", PdilemmaWebLive, :index
  end

end
