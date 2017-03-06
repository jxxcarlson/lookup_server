defmodule LookupPhoenix.Router do
  use LookupPhoenix.Web, :router

  # def assign_kv(conn, key_values) do
  #    Enum.reduce key_values, conn, fn {k, v}, conn ->
  #      Plug.Conn.assign(conn, k, v)
  #    end
  # end

  def assign_kv(conn, kv) do
    [k,v] = kv
    conn = Plug.Conn.assign(conn, k, v)
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    # plug :assign_kv, ["site", "foobar"]


    plug :put_secure_browser_headers
    plug LookupPhoenix.Auth, repo: LookupPhoenix.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LookupPhoenix do
    pipe_through :browser # Use the default browser stack

    resources "/notes", NoteController
    resources "/users", UserController, only: [:index, :show, :new, :create, :update, :delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete ]

    get "/random", SearchController, :random
    get "/recent", SearchController, :recent
    get "/tags", UserController, :tags

    post "/search", SearchController, :index
    get "/tag_search/:query", SearchController, :tag_search

    get "/update_tags", UserController, :update_tags
    post "/update_channel", UserController, :update_channel
    post "/toggle_lock", UserController, :toggle_lock
    get "/preferences", UserController, :show_preferences
    post "/preferences", UserController, :update_preferences


    get "/tips", PageController, :tips
    get "/demo", PageController, :demo

    get "/share/:id", PublicController, :share
    get "/public/:id", PublicController, :show
    get "/site/:site", PublicController, :index
    get "/sites", PublicController, :site_index
    get "/random_site", PublicController, :random_site
    post "/site", PublicController, :site

    get "/mailto/:id", NoteController, :mailto


    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", LookupPhoenix do
  #   pipe_through :api
  # end
end
