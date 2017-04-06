defmodule LookupPhoenix.NoteApiView do
  use LookupPhoenix.Web, :view

  alias LookupPhoenix.Utility

   def render("error.json", %{message: message}) do
      %{error: message}
    end

  def render("index.json", %{notes: notes}) do
    %{data: render_many(notes, LookupPhoenix.NoteApiView, "note.json")}
  end

  def render("show.json", %{result: result}) do
    %{data: render_one(result, LookupPhoenix.NoteApiView, "note.json")}
  end

  def render("note.json", %{result: result}) do
    Utility.report("RESULT", result)
    Utility.report("RESULT . NOTE", result.note)
    note = result.note
    %{id: note.id,
      title: note.title,
      content: note.content,
      tag_string: note.tag_string,
      rendered_text: result.rendered_text,
      inserted_at: result.inserted_at,
      updated_at: result.updated_at,
      options: result.options,
      word_count: result.word_count,
      sharing_is_authorized: result.sharing_is_authorized,
      current_id: note.id,
      channela: result.channela,

        first_index: 0,
        index: result.index,
        last_index: result.last_index,
        previous_index: result.previous_index,
        next_index: result.next_index,
        first_id: result.first_id,
        last_id: result.last_id,
        previous_id: result.previous_id,
        current_id: result.current_id,
        next_id: result.next_id,
        id_string: result.id_string,
        id_list: result.id_list,
        note_count: result.note_count,
        channel: result.channel
    }
  end

end
