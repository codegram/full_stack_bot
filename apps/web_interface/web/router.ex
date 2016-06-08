defmodule WebInterface.Router do
  use WebInterface.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WebInterface do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/webhook", WebInterface do
    pipe_through :api

    post "/", WebhookController, :recv
  end
end
