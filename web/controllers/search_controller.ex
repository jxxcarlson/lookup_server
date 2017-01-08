defmodule LookupPhoenix.SearchController do
    use LookupPhoenix.Web, :controller
    alias LookupPhoenix.Note

    def index(conn, %{"search" => %{"query" => query}}) do

      queryList = String.split(query)
      notes = LookupPhoenix.Note.search(queryList)

      noteCount = length(notes)
      case noteCount do
        1 -> noteCountString = "1 Note"
        _ -> noteCountString = Integer.to_string(noteCount) <> " Notes"
      end

      render(conn, "index.html", notes: notes, noteCountString: noteCountString)
    end


end



