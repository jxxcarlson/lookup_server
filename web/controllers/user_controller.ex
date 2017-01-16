defmodule LookupPhoenix.UserController do
  use LookupPhoenix.Web, :controller

  alias LookupPhoenix.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new_user.html", changeset: changeset
  end



  end
