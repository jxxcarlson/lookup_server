defmodule LookupPhoenix.NoteShowAction do

  alias LookupPhoenix.User
  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility
  alias LookupPhoenix.NoteNavigation

  alias MU.RenderText

  @moduledoc """
  INPUTS: conn, note id

  COMPUTATIONS:

  OUTPUTS:
        note: note,
        rendered_text: rendered_text,
        inserted_at: inserted_at,
        updated_at: updated_at,
        options: options,
        word_count: word_count,
        sharing_is_authorized: sharing_is_authorized,
        current_id: note.id,
        navigation_params

"""

  def call(user_name, query_string, note_id) do

     # username: current user
     note = Note.get(note_id)
     user = Repo.get!(User, note.user_id)
     if query_string == nil || query_string == "" do
       query_string = "index=0&id_string=#{note_id}"
     end
     Note.update_viewed_at(note)

     # Note.add_options(note) -- adds the options
     #    process: "latex" | "none"
     #    collate: true | false
     options = %{mode: "show", username: user_name, public: note.public} |> Note.add_options(note)
     Utility.report("SHOW, OPTIONS", options)
     # content = "== " <> note.title <> "\n\n" <> note.content
     content = note.content
     rendered_text = String.trim(RenderText.transform(content, options))
     rendered_text = "<h1>#{note.title}</h1>\n\n" <> rendered_text

     inserted_at= Note.inserted_at_short(note)
     updated_at= Note.updated_at_short(note)
     word_count = RenderText.word_count(note.content)

     sharing_is_authorized = true #  conn.assigns.current_user.id == note.user_id

     out_params = %{
        note: note,
        title: note.title,
        rendered_text: rendered_text,
        inserted_at: inserted_at,
        updated_at: updated_at,
        options: options,
        word_count: word_count,
        sharing_is_authorized: sharing_is_authorized,
        current_id: note.id,
        channela: user.channel
     }

     navigation_params = NoteNavigation.get(query_string, note_id)

     Map.merge(out_params, %{nav: navigation_params})

  end


end