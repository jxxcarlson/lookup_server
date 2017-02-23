defmodule LookupPhoenix.UserController do
  use LookupPhoenix.Web, :controller
  plug :authenticate when action in [:index, :show]

  alias LookupPhoenix.User
  alias LookupPhoenix.Tag
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility
  alias LookupPhoenix.SearchController
  alias LookupPhoenix.Constant


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

    def filter_by_frequency(tag_list, threshold) do
      Enum.filter(tag_list, fn(tag) -> tag["freq"] > Constant.tag_frequency_threshold() end)
    end

    def cookies(conn, cookie_name) do
      conn.cookies[cookie_name]
    end

  def tags(conn, _params) do
  IO.puts "HEY, TAGS!!"
     user = conn.assigns.current_user
     if user == nil do
       real_access = "public"
       channel_user_name = cookies(conn, "site")
       user = User.find_by_username(channel_user_name)
       if user == nil do
         user = User.find_by_username("demo")
       end
     end
     Utility.report("In User.tags, user is", user)
     [access, channel_name, user_id] = User.decode_channel(user)
     access = real_access || access
     if user_id == user.id and real_access != "public" do
       channel_user = user
       ctags = user.tags
       original_tag_count = length(ctags)
       ctags = ctags |> filter_by_frequency(Constant.tag_frequency_threshold())
       ctag_count = length(ctags)
     else
       channel_user = User |> Repo.get!(user_id)
       ctags = channel_user.public_tags
       original_tag_count = length(ctags)
       ctags = ctags |> filter_by_frequency(Constant.tag_frequency_threshold())
       original_tag_count = length(ctags)
       ctag_count = length(ctags)
     end
     render conn, "tags.html", user: channel_user,
        ctags: ctags, ctag_count: ctag_count, original_tag_count: original_tag_count
  end

  def update_tags(conn, _params) do
    User.update_tags(conn.assigns.current_user)
    conn |> redirect(to: user_path(conn, :tags))
    # render conn, "tags.html", user: conn.assigns.current_user
  end

  def update_channel(conn, params) do
      IO.puts "UPDATE CHANNEL"
      user = conn.assigns.current_user
      channel = (params["set"])["channel"]

      # Ensure that the channel has the form a.b
      channel_parts = channel |> String.split(".")
      channel_parts_head = hd(channel_parts)
      if channel_parts_head == "" do
        channel_parts = [user.username, "all"]
      end
      case length(channel_parts) do
        1 -> [channel_user_name, channel_name] = [user.username, hd(channel_parts)]
        2 -> [channel_user_name, channel_name] = channel_parts
        _ -> [user.username, "all"]
      end

      # Ensure that the 'channel_user_name' is valid
      if channel_user_name != user.username do
        channel_user = User.find_by_username(channel_user_name)
        if channel_user  == nil do
          IO.puts "NIL USER "
          # default to username of current user
          channel_user_name = user.username
        end
      end

      # Assemble the channel from known valid parts and save it
      channel = "#{channel_user_name}.#{channel_name}"
      User.update_channel(user, channel)
      conn |> redirect(to: note_path(conn, :index, mode: "all"))
    end



  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def createUser(changeset, conn) do
    IO.puts "Hello: createUser"
    case Repo.insert(changeset) do
          {:ok, user} ->
            IO.puts "User.createUser, :ok"
            User.initialize_metadata(user)
            IO.puts "AFTER: initialize_metadata"
            User.set_admin(user, false)
            conn
            |> LookupPhoenix.Auth.login(user)
            |> put_flash(:info, "#{Utility.firstWord(user.name)}, you are now a LookupNote user!")
            |> redirect(to: note_path(conn, :index))
          {:error, changeset} ->
            IO.puts "ERROR in createUser"
            render(conn, "new.html", changeset: changeset)
        end
  end

  def create(conn, %{"user" => user_params}) do
    IO.puts "UserController.create"
    username = user_params["username"]
    channel = "#{username}.all"
    user_params = Map.merge(user_params, %{"channel" => channel})
    changeset = User.registration_changeset(%User{}, user_params)
    Utility.report("create, changeset", changeset)

    preflight_check = cond do
      user_params["registration_code"] == "" ->
           {:error, "Sorry, a registration code is required."}
      Enum.member?(["lattice", "student", "uahs"], user_params["registration_code"]) == false ->
           {:error, "Sorry, that is not a valid registration code."}
      true -> {:ok, :proceed}
    end
    Utility.report("preflight_check", preflight_check)

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
