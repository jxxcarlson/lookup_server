defmodule LookupPhoenix.NoteShow2Action do

  alias LookupPhoenix.Note
  alias LookupPhoenix.User
  alias LookupPhoenix.Repo
  alias MU.TOC
  alias MU.RenderText
  alias LookupPhoenix.Utility
  alias LookupPhoenix.NoteNavigation
  alias LookupPhoenix.AppState


  # def show2(conn, %{"id" => id, "id2" => id2, "toc_history" => toc_history}) do

  def call(conn,%{"id" => id, "id2" => id2, "toc_history" => toc_history}) do

      th = toc_history
      IO.puts "!!!! TOC_HISTORY = #{toc_history}"
      qsMap = Utility.qs2map(conn.query_string)
      note = Note.get(id); id = note.id
      note2 = Note.get(id2); id2 = note2.id

     history_string = "#{id}>#{id2}"

     current_user = conn.assigns.current_user
     TOC.update_toc_history2(current_user, note, note2)

      user = Repo.get!(User, note.user_id)

      Note.update_viewed_at(note)

      # Note.add_options(note) -- adds the options
      #    process: "latex" | "none"
      #    collate: true | false
      options = %{mode: "show", username: conn.assigns.current_user.username,
         public: note.public, toc_history: history_string,
         path_segment: "show2"} |> Note.add_options(note)
      options2 = %{mode: "show", username: conn.assigns.current_user.username,
         public: note.public, toc_history: history_string,} |> Note.add_options(note2)
      rendered_text = String.trim(RenderText.transform(note.content, options))
      # content2 = "== " <> note2.title <> "\n\n" <> note2.content
      content2 = note2.content

      rendered_text2 = String.trim(RenderText.transform(content2, options2))
      rendered_text2 = "<h1 id=\"active_note:#{note2.id}\">#{note2.title}</h1>\n\n" <> rendered_text2
      rendered_text2 = "<h4><a href=\"/notes/#{note.id}\">#{note.title}</a></h4>\n\n" <> rendered_text2
      rendered_text2 = String.replace(rendered_text2, ":SELF", "show2/#{id}/#{id2}/#{th}")


      inserted_at= Note.inserted_at_short(note)
      updated_at= Note.updated_at_short(note)
      word_count = RenderText.word_count(note2.content)

      sharing_is_authorized = true #  conn.assigns.current_user.id == note.user_id

      params1 = %{note: note, note2: note2, parent: note, rendered_text: rendered_text, rendered_text2: rendered_text2,
                    inserted_at: inserted_at, updated_at: updated_at,
                    options: options, word_count: word_count, history_links: TOC.history_links2(conn.assigns.current_user),
                    sharing_is_authorized: sharing_is_authorized, current_id: note.id, channela: user.channel}

      conn_query_string = conn.query_string || ""
      cond do
        conn_query_string == "" ->
          query_string = "index=0&id_string=#{id}"
        !Regex.match?(~r/index=/,conn_query_string) ->
          query_string =  conn_query_string <> "&index=0&id_string=#{id}"
        true ->  query_string =  conn_query_string
      end

      # Get id_list and ensure that id2 is in it
      id_list = AppState.get(:user, current_user.id, :search_history)
      Utility.report("note_show2_action, id_list", id_list)
      if !Enum.member?(id_list, id2) do
        id_list = [id2|id_list]
        AppState.update(:user, current_user.id, :search_history, id_list)
      end
      params2 = NoteNavigation.get(id_list, id2)
      params = Map.merge(params1, params2)

      Map.merge(params, %{ history_string: history_string})
  end

end