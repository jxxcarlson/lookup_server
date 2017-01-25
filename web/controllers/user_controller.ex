defmodule LookupPhoenix.UserController do
  use LookupPhoenix.Web, :controller
  plug :authenticate when action in [:index, :show]

  alias LookupPhoenix.User
  alias LookupPhoenix.Tag
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility


  def index(conn, _params) do
    if conn.assigns.current_user.admin == true do
        query = Ecto.Query.from user in User,
                  # select: note.id,
                  # where: note.user_id == ^user_id and note.updated_at >= ^then,
                  order_by: [asc: user.id]
        users = Repo.all(query)
        render conn, "index.html", users: users
      else
        conn
        |> put_flash(:error, "Sorry, you do no have access to that page")
        |> redirect(to: page_path(conn, :index))
        |> halt
    end
  end

  def delete(conn, %{"id" => id}) do
      if conn.assigns.current_user.admin == true do
         user = Repo.get!(User, id)
         User.update_read_only(user, !user.read_only)
         user = Repo.get!(User, id)
         if user.read_only == true do
           message = "locked"
         else
           message = "unlocked"
         end
         conn
         |> put_flash(:info, "#{user.username} is #{message}")
         |> redirect(to: user_path(conn, :index))
      else
          conn
          |> put_flash(:error, "Sorry, you do no have access to that page")
          |> redirect(to: page_path(conn, :index))
          |> halt
      end
    end


  def tags(conn, _params) do
     render conn, "tags.html", user: conn.assigns.current_user
  end

  def update_tags(conn, _params) do
    User.update_tags(conn.assigns.current_user.id)
    conn |> redirect(to: user_path(conn, :tags))
    # render conn, "tags.html", user: conn.assigns.current_user
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def createUser(changeset, conn) do
    case Repo.insert(changeset) do
          {:ok, user} ->
            User.initialize_metadata(user)
            conn
            |> LookupPhoenix.Auth.login(user)
            |> put_flash(:info, "#{Utility.firstWord(user.name)}, you are now a LookupNote user!")
            |> redirect(to: note_path(conn, :index))
          {:error, changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
  end

  def create(conn, %{"user" => user_params}) do

    changeset = User.registration_changeset(%User{}, user_params)

    preflight_check = cond do
      user_params["registration_code"] == "" ->
           {:error, "Sorry, a registration code is required."}
      Enum.member?(["ladidah", "student", "uahs"], user_params["registration_code"]) == false ->
           {:error, "Sorry, that is not a valid registration code."}
      true -> {:ok, :proceed}
    end
    IO.inspect preflight_check

    case  preflight_check do
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: user_path(conn, :new))
      _ -> createUser(changeset, conn)
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
