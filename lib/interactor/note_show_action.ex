defmodule LookupPhoenix.NoteShowAction do

  alias LookupPhoenix.User
  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility
  alias LookupPhoenix.NoteNavigation
  alias LookupPhoenix.AppState

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

     IO.puts "(XX:1) enter NoteShowAction"

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

     parent_note = Note.get_parent(note)
     Utility.report("(XX:1) parent id", note.parent_id)
     if parent_note != nil do
       IO.puts "(XX:1) found parent note"
       rendered_text = "<h4><a href=\"/notes/#{parent_note.id}\">#{parent_note.title}</a></h4>\n\n" <> rendered_text
     else
       IO.puts "(XX:1) did not find parent note"
     end

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

     id_list = AppState.get(:user, user.id, :search_history)

     navigation_params = NoteNavigation.get(id_list, note_id)

     Map.merge(out_params, %{nav: navigation_params})

  end


end