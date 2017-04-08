defmodule LookupPhoenix.NoteUpdateAction do

  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Identifier
  alias LookupPhoenix.Tag
  alias LookupPhoenix.NoteNavigation
  alias LookupPhoenix.Utility

  alias MU.RenderText
  alias MU.LiveNotebook

  @moduledoc """
  The NoteUpdateAction module has one public method, 'call', whose purpose
  is to update a note.

  INPUTS:

    - username
    - note
    - note_params
      - title
      - content
      - tag_string
      - identifier
      - public
      - idx
      - nav

  COMPUTED:

    - tags (from tag_string)
    - edited_at (the date-time via Timex)
    - rendered_text
    - word_count
    - locked

  OUTPUTS:

    - params
      - changeset
      - rendered_text
      - random
      - locked
      - word_count
    - udpdate_result
      {:ok, note} | {:error, message}
    - nav
      :channel, :current_id, :first_id, :first_index, :id_list, :id_string, :index,
      :last_id, :last_index, :next_id, :next_index, :note_count, :previous_id,
      :previous_index



"""

  def call(username, note, note_params) do

     locked = false

     content = note_params["content"]
     title = note_params["title"]
     tags = Tag.str2tags(note_params["tag_string"])

     parent_note = Note.get_parent_from_tags(note)
     if parent_note != nil do
       parent_id = parent_note.id
       IO.puts "(XX) Setting parent of #{note.title} to #{parent_note.title}"
     else
       parent_id = nil
       IO.puts "(XX) Could not find parent"
     end

     new_params = Map.merge(note_params, %{
        "content" => content,
        "title" => title,
        "tags" => tags,
        "edited_at" => Timex.now,
        "parent_id" => parent_id
      })

     options =  Note.add_options(%{mode: "show", public: note.public, toc_history: "", path_segment: "show2"}, note)
     rendered_text = RenderText.transform(content, options)

     # Update database
     changeset = Note.changeset(note, Map.delete(new_params, :nav))
     changeset = Ecto.Changeset.update_change(changeset, :identifier, fn(ident) -> Identifier.normalize(username, ident) end)

     if !locked do
       update_result = Repo.update(changeset)
     else
       update_result = {:error, "Could note update note"}
     end

     # If the note is a master note (index note), then update it
     tags = note.tags || []
     live_tags = tags |> Enum.filter(fn(tag) -> Regex.match?(~r/live/, tag) end)
     if live_tags != [] do LiveNotebook.update(note) end

     params = %{
       changeset: changeset,
       rendered_text: rendered_text,
       random: "no",
       locked: locked,
       word_count: RenderText.word_count(note.content),
     }

     navigation_parameters = params["nav"]
     %{params: params, update_result: update_result, nav: new_params[:nav]}

  end

end