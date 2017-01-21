defmodule LookupPhoenix.Router do
  use LookupPhoenix.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug LookupPhoenix.Auth, repo: LookupPhoenix.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LookupPhoenix do
    pipe_through :browser # Use the default browser stack

    resources "/notes", NoteController
    resources "/users", UserController, only: [:index, :show, :new, :create, :delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete ]

    get "/random", SearchController, :random
    get "/tags", UserController, :tags

    post "/search", SearchController, :index
    get "/tag_search:query", SearchController, :tag_search

    get "/update_tags", UserController, :update_tags
    post "/toggle_lock", UserController, :toggle_lock


    get "/tips", PageController, :tips
    get "/demo", PageController, :demo


    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", LookupPhoenix do
  #   pipe_through :api
  # end
end
