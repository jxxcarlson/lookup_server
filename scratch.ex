if note == nil do
     render(conn, "error.html", %{})
 else
     options = %{mode: "show", process: "none"}
     params = %{note: note, options: options}
     case [note.public, note.shared] do
       [true, _] -> render(conn, "share.html", params, title: "LookupNotes: Public")
       [_, true] ->
          if Note.match_token_array(token, note) do render(conn, "share.html", params, title: "LookupNotes: Shared") end
       _ ->  render(conn, "error.html", params)
     end
 end