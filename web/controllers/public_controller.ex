defmodule LookupPhoenix.PublicController do
  use LookupPhoenix.Web, :controller
  # plug LookupPhoenix.Plug.Site, site: "foo"
    alias LookupPhoenix.Note
    alias LookupPhoenix.User
    alias LookupPhoenix.Utility
    alias LookupPhoenix.Search
    alias LookupPhoenix.Constant
    alias LookupPhoenix.NoteNavigation
    alias LookupPhoenix.TokenManager
    alias MU.RenderText
    alias MU.TOC


   def share(conn, %{"id" => id}) do
         note = Note.get(id)
         token = conn.query_string
         user = Repo.get(User, note.user_id)
         site = user.username

         options = %{mode: "show"} |> Note.add_options(note)


         # plug LookupPhoenix.Plug.Site, site: site


         # options = %{mode: "show", process: "none"}
         params = %{note: note, site: site, options: options}


         case [note.public, note.shared] do
            [true, _] ->  render(conn, "share.html", params) # redirect(conn, to: public_path(conn, :show, params))
            [_, true] ->
               if TokenManager.match_token_array(token, note) do render(conn, "share.html", params) end
            _ ->  render(conn, "error.html", params) #                                                                                     `````````````````|> put_resp_cookie("site", site)
          end

     end

  def do_show(conn, %{"id" => id, "site" => site}) do
      note = Note.get(id)
      user = Repo.get!(User, note.user_id)
      token = conn.query_string

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
          params2 = NoteNavigation.get(query_string, nil)
          params = Map.merge(params1, params2)

          case note.public do
            true -> render(conn, "show.html", Map.merge(params, %{title: "LookupNotes: Public"})) |> put_resp_cookie("site", site)
            false ->
               if is_map(token) and TokenManager.match_token_array(token, note) do
                 render(conn, "show.html", Map.merge(params, %{title: "LookupNotes: Shared"})) |> put_resp_cookie("site", site)
               else
                 render(conn, "error.html", params)
               end
          end
      end
      # match_token_array
  end


  defp do_show2(conn, note) do
      text = note.content
      lines =  String.split(String.trim(text), ["\n", "\r", "\r\n"])
      |> Enum.filter(fn(line) -> !Regex.match?(~r/^title/, line) end)
      first_line  = hd(lines)
      [id2, _] = String.split(first_line, ",")
      redirect(conn, to: "/public/#{note.id}/#{id2}/#{note.id}>#{id2}")
  end

   def show2(conn, %{"id" => id, "id2" => id2, "toc_history" => toc_history}) do

        qsMap = Utility.qs2map(conn.query_string)
        note = Note.get(id); id = note.id
        note2 = Note.get(id2); id2 = note2.id

       toc_history = TOC.update_toc_history(toc_history, note, note2)
       history_string = TOC.make_history_string(toc_history)
       history_links = TOC.make_history_links(toc_history)

       TOC.make_history(toc_history)


        user = Repo.get!(User, note.user_id)
        site = user.username ##### XXXX

        Note.update_viewed_at(note)

        # Note.add_options(note) -- adds the options
        #    process: "latex" | "none"
        #    collate: true | false
        options = %{mode: "show", username: user.username, public: note.public,
           toc_history: history_string, path_segment: "public"} |> Note.add_options(note)
        options2 = %{mode: "show", username: user.username, public: note.public, toc_history: history_string} |> Note.add_options(note2)
        rendered_text = String.trim(RenderText.transform(note.content, options))
        content2 = "== " <> note2.title <> "\n\n" <> note2.content
        rendered_text2 = String.trim(RenderText.transform(content2, options2))

        inserted_at= Note.inserted_at_short(note)
        updated_at= Note.updated_at_short(note)
        word_count = RenderText.word_count(note.content)

        sharing_is_authorized = true #  conn.assigns.current_user.id == note.user_id

        params1 = %{note: note, note2: note2, parent: note, rendered_text: rendered_text, rendered_text2: rendered_text2,
                      inserted_at: inserted_at, updated_at: updated_at, site: site,
                      options: options, word_count: word_count, history_links: history_links,
                      sharing_is_authorized: sharing_is_authorized, current_id: note.id, channela: user.channel}

        conn_query_string = conn.query_string || ""
        cond do
          conn_query_string == "" ->
            query_string = "index=0&id_string=#{id}"
          !Regex.match?(~r/index=/,conn_query_string) ->
            query_string =  conn_query_string <> "&index=0&id_string=#{id}"
          true ->  query_string =  conn_query_string
        end

        params2 = NoteNavigation.get_string(query_string)
        params = Map.merge(params1, params2)



         params = Map.merge(params, %{toc_history: Enum.join(toc_history, ","), history_string: history_string})
         render(conn, "show2.html", params)
      end # SHOW

   def show(conn, %{"id" => id, "site" => site}) do

      note = Note.get(id)

      if Enum.member?(note.tags, ":toc") do
        do_show2(conn, note)
      else
        do_show(conn, %{"id" => id, "site" => site})
      end

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
        user = User.find_by_username(site)
         channel = user.channel
         [channel_name, _] = String.split(channel, ".")
          access = :public
         notes = Search.tag_search([qsMap["tag"]], channel, access)
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
