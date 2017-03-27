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
         Utility.report("NOTE", note)
         Utility.report("id", id)
         Utility.report("token", token)
         user = Repo.get(User, note.user_id)
         site = user.username

         options = %{mode: "show"} |> Note.add_options(note)

        Utility.report("OPTIONS IN PUBLIC:SHARE", options)

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
      user = Repo.get!(User, note.user_id)
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
          params1 = %{note: note, options: options, site: site, channela: user.channel}
          params2 = Note.decode_query_string(query_string)
          params = Map.merge(params1, params2)

          case note.public do
            true -> render(conn, "show.html", Map.merge(params, %{title: "LookupNotes: Public"})) |> put_resp_cookie("site", site)
            false ->
               if is_map(token) and Note.match_token_array(token, note) do
                 render(conn, "show.html", Map.merge(params, %{title: "LookupNotes: Shared"})) |> put_resp_cookie("site", site)
               else
                 render(conn, "error.html", params)
               end
          end
      end
      # match_token_array
  end


  def index(conn, params) do

    current_user = conn.assigns.current_user
    site = params["site"]
    qsMap = Utility.qs2map(conn.query_string)

    cond do
       current_user == nil ->
         channel = site <> ".public"
         access = %{"access" => :public}
       current_user.username == site ->
         channel = site <> ".all"
         User.set_channel(current_user, channel)
         access = %{"access" => :all}
       true ->
         channel = site <>  ".public"
         User.set_channel(current_user, channel)
         access = %{"access" => :public}
     end

    cond do
      qsMap["random"] == "one" ->
        note_record = Search.notes_for_channel(channel, access)
        note = note_record.notes
        |> Utility.random_element
        notes = [note]
      qsMap["tag"] != nil ->
        notes = Search.tag_search([qsMap["tag"]], conn)
      true ->
        note_record = Search.notes_for_channel(channel, access)
        notes = note_record.notes
    end
    notes = Utility.add_index_to_maplist(notes)

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
        IO.puts "SITE: redirect to /notes"
        conn
        |> put_resp_cookie("site", site)
        |> redirect(to: "/notes")
     else
        IO.puts "SITE: redirect to /site/:site"
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
