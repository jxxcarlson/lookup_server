defmodule LookupPhoenix.NoteShow2Action do

  alias LookupPhoenix.Note
  alias LookupPhoenix.User
  alias LookupPhoenix.Repo
  alias MU.TOC
  alias MU.RenderText
  alias LookupPhoenix.Utility
  alias LookupPhoenix.NoteNavigation


  # def show2(conn, %{"id" => id, "id2" => id2, "toc_history" => toc_history}) do

  def call(conn,%{"id" => id, "id2" => id2, "toc_history" => toc_history}) do

      qsMap = Utility.qs2map(conn.query_string)
      note = Note.get(id); id = note.id
      note2 = Note.get(id2); id2 = note2.id

     toc_history = TOC.update_toc_history(toc_history, note, note2)
     history_string = TOC.make_history_string(toc_history)
     history_links = TOC.make_history_links(toc_history)

     TOC.make_history(toc_history)


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
      content2 = "== " <> note2.title <> "\n\n" <> note2.content
      rendered_text2 = String.trim(RenderText.transform(content2, options2))

      inserted_at= Note.inserted_at_short(note)
      updated_at= Note.updated_at_short(note)
      word_count = RenderText.word_count(note.content)

      sharing_is_authorized = true #  conn.assigns.current_user.id == note.user_id

      params1 = %{note: note, note2: note2, parent: note, rendered_text: rendered_text, rendered_text2: rendered_text2,
                    inserted_at: inserted_at, updated_at: updated_at,
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

      params2 = NoteNavigation.decode_query_string(query_string)
      params = Map.merge(params1, params2)

      Map.merge(params, %{toc_history: Enum.join(toc_history, ","), history_string: history_string})
  end

end