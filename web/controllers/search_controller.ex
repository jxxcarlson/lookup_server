defmodule LookupPhoenix.SearchController do
    use LookupPhoenix.Web, :controller
    alias LookupPhoenix.Note

    def index(conn, %{"search" => %{"query" => query}}) do
      queryList = String.split(query)
      notes = LookupPhoenix.Note.search(queryList)

      render(conn, "index.html", notes: notes, count: length(notes))
    end


end



