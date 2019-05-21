defmodule MpdWeb.Router do
  use MpdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    use Plug.ErrorHandler
    use Sentry.Plug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MpdWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/call/:id", PageController, :calls

    get "/about", PageController, :about
    get "/contribute", PageController, :contribute
    get "/bulk", PageController, :bulk
  end

  # Other scopes may use custom stacks.
  # scope "/api", MpdWeb do
  #   pipe_through :api
  # end
end
