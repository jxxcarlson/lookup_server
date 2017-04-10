defmodule LookupPhoenix.NotePrintAction do

  alias LookupPhoenix.User
  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility
  alias LookupPhoenix.NoteNavigation

  alias MU.RenderText

  @moduledoc """

"""

  def call(note_id) do

     IO.puts "(XX:2) enter NotePringAction"
     note = Note.get(note_id)
     options = %{ mode: "show" } |> Note.add_options(note)
     Utility.report("SHOW, OPTIONS", options)
     content = "== " <> note.title <> "\n\n" <> note.content
     rendered_text = String.trim(RenderText.transform(content, options))
     rendered_text = "<h1>#{note.title}</h1>\n\n" <> rendered_text
     %{rendered_text: rendered_text, note_id: note_id}

  end


end