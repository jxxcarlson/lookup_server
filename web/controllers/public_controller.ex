defmodule LookupPhoenix.PublicController do
  use LookupPhoenix.Web, :controller
  # plug LookupPhoenix.Plug.Site, site: "foo"
    alias LookupPhoenix.Note
    alias LookupPhoenix.User
    alias LookupPhoenix.Utility
    alias LookupPhoenix.Search
    alias LookupPhoenix.Constant


   def share(conn, %{"id" => id}) do
         note = Note.get(id)
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
      note = Note.get(id)
      token = conn.query_string
      Utility.report("token", token)

      if note == nil do
          render(conn, "error.html", %{})
      else
          conn_query_string = conn.query_string || ""
          if conn_query_string == "" do
            query_string = "index=0&id_string=#{note.id}"
          else
            query_string = conn_query_string
          end

          options = %{mode: "show"} |> Note.add_options(note)
          params1 = %{note: note, options: options, site: site}
          params2 = Note.decode_query_string(query_string)
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

  def get_channel(site_string) do
    # Define site and channel, with default channel = "public"
    # site_string = params["site"]
    if !String.contains?(site_string, ".") do
      site_string = site_string <> ".public"
    end
    [site, channel_name] = String.split(site_string, ".")
    channel = "#{site}.#{channel_name}"

    user = User.find_by_username(site)

    # Ensure that site, channel, user a well-defined
    if user == nil do
      user = Repo.get!(User, Constant.default_site_id())
      site = user.username
      channel = "#{site}.public"
    end
    [site, channel_name, channel]
  end

  # def index(conn, %{"site" => site}) do
  def index(conn, params) do

    qsMap = Utility.qs2map(conn.query_string)

    IO.puts "PUBLIC . INDEX"
    Utility.report("params", params)
    IO.puts "INDEX, conn.request_path = #{conn.request_path}"

    [site, channel_name, channel] = get_channel(params["site"])

    # if conn.assigns.current_user != nil do
    #   User.set_channel( conn.assigns.current_user, channel)
    #  IO.puts "I HAVE SET YOUR CHANNEL TO #{channel}"
    # end

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
     current_user = conn.assigns.current_user
     IO.puts "site = #{site}"
     if current_user != nil and current_user.username == site do
        conn
        |> put_resp_cookie("site", site)
        |> redirect(to: "/notes")
     else
        conn
        |> put_resp_cookie("site", site)
        |> redirect(to: "/site/#{site}")
     end


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
