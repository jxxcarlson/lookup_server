# require IEx

defmodule LookupPhoenix.SearchController do
    use LookupPhoenix.Web, :controller
    alias LookupPhoenix.Note

    def index(conn, %{"search" => %{"query" => query}}) do


      queryList = String.split(query)
      notes = LookupPhoenix.Note.search(queryList, conn.assigns.current_user.id)
      LookupPhoenix.Note.memorize_notes(notes, conn.assigns.current_user.id)

      noteCount = length(notes)
      case noteCount do
        1 -> noteCountString = "1 Note"
        _ -> noteCountString = Integer.to_string(noteCount) <> " Notes"
      end

      render(conn, "index.html", notes: notes, noteCountString: noteCountString)


    end


    def random(conn, _params) do
      expected_number_of_entries = 14
      # note_count = Note.count_notes_user(conn.assigns.current_user.id)
      user_id = conn.assigns.current_user.id
      note_count = Note.count_for_user(user_id)

      cond do
        note_count > 6 ->
           p = (100*expected_number_of_entries) / note_count
           notes = LookupPhoenix.Note.random_notes_for_user(p, conn.assigns.current_user.id)
        note_count <= 5 ->
           notes = Note.notes_for_user(user_id)
      end
      LookupPhoenix.Note.memorize_notes(notes, conn.assigns.current_user.id)



      case note_count do
        1 -> countReportString =   "1 Random note"
        _ -> countReportString = "#{length(notes)} Random notes"
      end
      render(conn, "index.html", notes: notes, noteCountString: countReportString)
    end


end



