defmodule LookupPhoenix.SearchController do
    use LookupPhoenix.Web, :controller

    def index(conn, %{"search" => %{"query" => query}}) do
      IO.puts query
      results = "foo" # do the actual search using `query`
      render conn, "index.html", results: results
    end

end



