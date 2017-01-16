defmodule LookupPhoenix.UserController do
  use LookupPhoenix.Web, :controller

  alias LookupPhoenix.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do

    changeset = User.changeset(%User{}, user_params)
    {:ok, user} = Repo.insert(changeset)

    conn|> put_flash(:info, "#{user.name}, you are now a Lookup user")
    |> redirect(to: note_path(conn, :index))
  end


  end
