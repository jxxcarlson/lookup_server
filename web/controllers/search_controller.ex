# require IEx

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


    def random(conn, _params) do
      expected_number_of_entries = 14
      p = (100*expected_number_of_entries) / Note.count
      notes = LookupPhoenix.Note.random(p) |> ListUtil.truncateAt(7)
      case length(notes) do
        1 -> countReportString =   "1 Random note"
        _ -> countReportString = "#{length(notes)} Random notes"
      end
      render(conn, "index.html", notes: notes, noteCountString: countReportString)
    end


end



