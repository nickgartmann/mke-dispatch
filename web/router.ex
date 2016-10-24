defmodule MkePolice.Router do
  use MkePolice.Web, :router

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

  scope "/", MkePolice do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/csv", PageController, :csv
    get "/map", PageController, :map
  end

  # Other scopes may use custom stacks.
  scope "/api", MkePolice do
    pipe_through :api
    get "/calls", PageController, :calls
  end
end
