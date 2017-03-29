defmodule LookupPhoenix.NoteUpdateAction do

  alias LookupPhoenix.Note
  alias LookupPhoenix.Identifier
  alias LookupPhoenix.Tag
  alias MU.RenderText
  alias MU.LiveNotebook


  def call(note, note_params, save_option, conn) do
     new_content = Regex.replace(~r/ß/, note_params["content"], "")
     new_title = Regex.replace(~r/ß/, note_params["title"], "")

     tags = Tag.str2tags(note_params["tag_string"])

     new_params = Map.merge(note_params, %{"content" => new_content, "title" => new_title,
         "tags" => tags, "edited_at" => Timex.now})

     changeset = Note.changeset(note, new_params)
     current_user = conn.assigns.current_user
     changeset = Ecto.Changeset.update_change(changeset, :identifier, fn(ident) -> Identifier.normalize(current_user, ident) end)

     index = conn.params["index"]
     id_string = conn.params["id_string"]
     params = Note.decode_query_string("index=#{index}&id_string=#{id_string}")
     params = Map.merge(params, %{random: "no"})
     rendered_text = RenderText.transform(new_content, Note.add_options(%{mode: "show", public: note.public, toc_history: ""}, note))

     if save_option != "exit"  do
       params = params_for_save(conn, note, params, changeset, rendered_text)
     end

     live_tags = note.tags |> Enum.filter(fn(tag) -> Regex.match?(~r/live/, tag) end)
     if live_tags != [] do LiveNotebook.update(note) end

     %{params: params, changeset: changeset}
  end

  defp params_for_save(conn, note, params, changeset, rendered_text) do
    locked = conn.assigns.current_user.read_only
    word_count = RenderText.word_count(note.content)

    params1 = %{note: note, changeset: changeset,
                            word_count: word_count, locked: locked,
                            conn: conn, rendered_text: rendered_text}

     params = Map.merge(params, params1)
  end



end