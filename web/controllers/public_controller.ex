defmodule LookupPhoenix.PublicController do
  use LookupPhoenix.Web, :controller
    alias LookupPhoenix.Note
    alias LookupPhoenix.User
    alias LookupPhoenix.Utility


  def show(conn, %{"id" => id}) do
      note  = Repo.get(Note, id)
      token = conn.query_string
      Utility.report("token", token)
      if note == nil do
          render(conn, "error.html", %{})
      else
          options = %{mode: "show", process: "none"}
          params = %{note: note, options: options}
          case [note.public, note.shared] do
            [true, _] -> render(conn, "show.html", params, title: "LookupNotes: Public")
            [_, true] ->
               if Note.match_token_array(token, note) do render(conn, "show.html", params, title: "LookupNotes: Shared") end
            _ ->  render(conn, "error.html", params)
          end
      end
      # match_token_array

  end

end
