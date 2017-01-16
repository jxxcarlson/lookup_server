defmodule LookupPhoenix.UserController do
  use LookupPhoenix.Web, :controller

  alias LookupPhoenix.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html.eex", changeset: changeset
  end



  end
