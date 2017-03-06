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


     def random(conn, _params) do

         IO.puts "HERE IS RANDOM"
         user = conn.assigns.current_user
         expected_number_of_entries = 14

         [access, channel_name, user_id] = User.decode_channel(user)

          User.increment_number_of_searches(conn.assigns.current_user)

         if Enum.member?(["all", "public"], channel_name) do
           raw_random(conn, expected_number_of_entries)
         else
           notes = Search.tag_search([channel_name], conn) |> RandomList.mcut |> Utility.add_index_to_maplist
           noteCountString = "#{length(notes)} random notes"
           id_string = notes |> Enum.map(fn(note) -> note.id end) |> Enum.join(",")
           render(conn, "index.html", notes: notes, id_string: id_string, noteCountString: noteCountString, index: 0)
         end

     end