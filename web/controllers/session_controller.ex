defmodule LookupPhoenix.SessionController do
  use LookupPhoenix.Web, :controller
  alias LookupPhoenix.Utility

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case LookupPhoenix.Auth.login_by_username_and_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back, #{Utility.firstWord(conn.assigns.current_user.name)}!")
        |> redirect(to: note_path(conn, :index, option: "recall_id_list"))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> LookupPhoenix.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end


end