defmodule LookupPhoenix.UserController do
  use LookupPhoenix.Web, :controller
  plug :authenticate when action in [:index, :show]

  alias LookupPhoenix.User
  alias LookupPhoenix.Tag


  def index(conn, _params) do
     users = Repo.all(LookupPhoenix.User)
     render conn, "index.html", users: users
  end

  def tags(conn, _params) do
     render conn, "tags.html", user: conn.assigns.current_user
  end

  def update_tags(conn, _params) do
    User.update_tags(conn.assigns.current_user.id)
    render conn, "tags.html", user: conn.assigns.current_user
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do

    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> LookupPhoenix.Auth.login(user)
        |> put_flash(:info, "#{user.name}, you are now a Lookup user")
        |> redirect(to: note_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be signed in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt
    end
  end


  end
