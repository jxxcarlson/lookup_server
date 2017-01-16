defmodule LookupPhoenix.UserController do
  use LookupPhoenix.Web, :controller

  alias LookupPhoenix.User

  def index(conn, _params) do
    users = Repo.all(LookupPhoenix.User)
    render conn, "index.html", users: users

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
        |> put_flash(:info, "#{user.name}, you are now a Lookup user")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end


  end
