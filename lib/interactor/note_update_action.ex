defmodule LookupPhoenix.NoteUpdateAction do

  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Identifier
  alias LookupPhoenix.Tag
  alias LookupPhoenix.NoteNavigation

  alias MU.RenderText
  alias MU.LiveNotebook

  @moduledoc """
  The NoteUpdateAction module has one public method, 'call', whose purpose
  is to update a note.

  INPUTS:

    - note
    - note_params
      - content
      - title
      - tag_string
      - WHAT ELSE?
    - conn
      - id_string
      - index

  COMPUTED:

    - tags (from tag_string)
    - edited_at (the date-time via Timex)
    - rendered_text
    - word_count
    - locked

  OUTPUTS:

    - changeset
    - rendered_text
    - random
    - locked
    - word_count
    - merged: navigation_parameters


"""

  def call(note, note_params, conn) do

     current_user = conn.assigns.current_user

     # Inputs -- fix spurious character if any left by keyboard shortcut (option s)
     content = Regex.replace(~r/ß/, note_params["content"], "")
     title = Regex.replace(~r/ß/, note_params["title"], "")

     # Computed values
     tags = Tag.str2tags(note_params["tag_string"])

     new_params = Map.merge(note_params, %{
        "content" => content,
        "title" => title,
        "tags" => tags,
        "edited_at" => Timex.now
      })

     options =  Note.add_options(%{mode: "show", public: note.public, toc_history: "", path_segment: "show2"}, note)
     rendered_text = RenderText.transform(content, options)

     # Update database
     changeset = Note.changeset(note, new_params)
     changeset = Ecto.Changeset.update_change(changeset, :identifier, fn(ident) -> Identifier.normalize(current_user, ident) end)
     update_result = Repo.update(changeset)

     # Compute navigation parameters needed by client
     index = conn.params["index"]
     id_string = conn.params["id_string"]
     navigation_parameters = NoteNavigation.get("index=#{index}&id_string=#{id_string}")

     # If the note is a master note (index note), then update it
     live_tags = note.tags |> Enum.filter(fn(tag) -> Regex.match?(~r/live/, tag) end)
     if live_tags != [] do LiveNotebook.update(note) end

     params = %{
       changeset: changeset,
       rendered_text: rendered_text,
       random: "no",
       locked: conn.assigns.current_user.read_only,
       word_count: RenderText.word_count(note.content),
     }

     params = Map.merge(params, navigation_parameters)

     %{params: params, update_result: update_result}
  end





end