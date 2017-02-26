defmodule LookupPhoenix.PublicController do
  use LookupPhoenix.Web, :controller
  # plug LookupPhoenix.Plug.Site, site: "foo"
    alias LookupPhoenix.Note
    alias LookupPhoenix.User
    alias LookupPhoenix.Utility
    alias LookupPhoenix.Search
    alias LookupPhoenix.Constant


   def share(conn, %{"id" => id}) do
         note  = Repo.get!(Note, id)
         token = conn.query_string
         Utility.report("id", id)
         Utility.report("token", token)
         user = Repo.get(User, note.user_id)
         site = user.username

         options = %{mode: "show"} |> Note.add_options(note)

        Utility.report("OPTIONS", options)

         # plug LookupPhoenix.Plug.Site, site: site

         Utility.report("PUBLIC_C . SHARE . SITE:", site)

         # options = %{mode: "show", process: "none"}
         params = %{note: note, site: site, options: options}

         Utility.report("[note.public, note.shared]", [note.public, note.shared])

         case [note.public, note.shared] do
            [true, _] ->  render(conn, "share.html", params) # redirect(conn, to: public_path(conn, :show, params))
            [_, true] ->
               if Note.match_token_array(token, note) do render(conn, "share.html", params) end
            _ ->  render(conn, "error.html", params) #                                                                                     `````````````````|> put_resp_cookie("site", site)
          end

     end



  def show(conn, %{"id" => id, "site" => site}) do
      note  = Repo.get(Note, id)
      token = conn.query_string
      Utility.report("token", token)

      if note == nil do
          render(conn, "error.html", %{})
      else
          options = %{mode: "show"} |> Note.add_options(note)
          params1 = %{note: note, options: options, site: site}
          params2 = Note.decode_query_string(conn.query_string)
          params = Map.merge(params1, params2)

          case note.public do
            true -> render(conn, "show.html", Map.merge(params, %{title: "LookupNotes: Public"})) |> put_resp_cookie("site", site)
            false ->
               if Note.match_token_array(token, note) do
                 render(conn, "show.html", Map.merge(params, %{title: "LookupNotes: Shared"})) |> put_resp_cookie("site", site)
               else
                 render(conn, "error.html", params)
               end
          end
      end
      # match_token_array
  end

  # def index(conn, %{"site" => site}) do
  def index(conn, params) do
    # Utility.report('CONN . ASSIGNS', conn.request_path)

    IO.puts "PUBLIC . INDEX"
    Utility.report("params", params)
    qsMap = Utility.qs2map(conn.query_string)

    IO.puts "INDEX, conn.request_path = #{conn.request_path}"

    site = params["site"]
    channel = "#{site}.public"
    user = User.find_by_username(site)

    # Ensure that site, channel, user a well-defined
    if user == nil do
      user = Repo.get!(User, Constant.default_site_id())
      site = user.username
      channel = "#{site}.public"
    end

    if conn.assigns.current_user != nil do
      User.set_channel( conn.assigns.current_user, channel)
      IO.puts "I HAVE SET YOUR CHANNEL TO #{channel}"
    end

    if qsMap["random"] == "one" do
      note_record = Search.notes_for_channel(channel, %{})
      notes = note_record.notes |> Utility.random_element
      notes = Utility.add_index_to_maplist([notes])
    else
      note_record = Search.notes_for_channel(channel, %{})
      notes = Utility.add_index_to_maplist(note_record.notes)
    end

    id_string = Note.extract_id_list(notes)
    params = %{site: site, notes: notes, note_count: length(notes), id_string: id_string}
    conn
      |> put_resp_cookie("channel", channel)
      |> put_resp_cookie("site", site)
      |> render("index.html", params)
  end

  def site(conn, params) do
     site = params["data"]["site"]
     IO.puts "site = #{site}"
     conn |> redirect(to: "/site/#{site}")

  end

  def site_index(conn, _params) do
    params = %{users: User.public_users}
    conn |> render("site_index.html", params)
  end

  def random_site(conn, _params) do
      user = User.public_users |> Utility.random_element
      IO.puts "RANDOM SITE, USER = #{user.username}"
      conn |> redirect(to: "/site/#{user.username}")
  end


end
