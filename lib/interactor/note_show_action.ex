defmodule LookupPhoenix.NoteShowAction do

  alias LookupPhoenix.User
  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility
  alias LookupPhoenix.NoteNavigation

  alias MU.RenderText

  def call(conn, note) do

       user = Repo.get!(User, note.user_id)

        Note.update_viewed_at(note)

        # Note.add_options(note) -- adds the options
        #    process: "latex" | "none"
        #    collate: true | false
        options = %{mode: "show", username: conn.assigns.current_user.username, public: note.public} |> Note.add_options(note)
        content = "== " <> note.title <> "\n\n" <> note.content
        rendered_text = String.trim(RenderText.transform(content, options))

        inserted_at= Note.inserted_at_short(note)
        updated_at= Note.updated_at_short(note)
        word_count = RenderText.word_count(note.content)

        sharing_is_authorized = true #  conn.assigns.current_user.id == note.user_id

        params1 = %{note: note, rendered_text: rendered_text,
                      inserted_at: inserted_at, updated_at: updated_at,
                      options: options, word_count: word_count,
                      sharing_is_authorized: sharing_is_authorized, current_id: note.id, channela: user.channel}


        conn_query_string = conn.query_string || ""
        if conn_query_string == "" do
          query_string = "index=0&id_string=#{note.id}"
        else
          query_string = conn_query_string
        end
        params2 = NoteNavigation.decode_query_string(query_string)

        params = Map.merge(params1, params2)
        result = %{params: params}
  end


end