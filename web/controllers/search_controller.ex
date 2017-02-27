# require IEx

defmodule LookupPhoenix.SearchController do
    use LookupPhoenix.Web, :controller
    alias LookupPhoenix.Note
    alias LookupPhoenix.Search
    alias LookupPhoenix.User
    alias LookupPhoenix.Utility

    def cookies(conn, cookie_name) do
       conn.cookies[cookie_name]
    end


    def index(conn, %{"search" => %{"query" => query}}) do

      current_user = conn.assigns.current_user

      if current_user == nil do
        query = "/public " <> query
        site = cookies(conn,"site")
        channel_user = User.find_by_username(site)
        user = channel_user
      else
        user = current_user
        User.increment_number_of_searches(user)
      end

      user_signed_in = current_user != nil
      notes = Search.search(query, user, %{user_signed_in: user_signed_in})
      if current_user != nil do
        Note.memorize_notes(notes, current_user.id)
      end

      notes = Utility.add_index_to_maplist(notes)
      id_string = Note.extract_id_list(notes)

      noteCount = length(notes)
      case noteCount do
        1 -> noteCountString = "1 Note found"
        _ -> noteCountString = Integer.to_string(noteCount) <> " Notes found"
      end

      IO.puts "XXX: SearchController, index, notes: #{length(notes)}"

      render(conn, "index.html", site: site, notes: notes, id_string: id_string, noteCountString: noteCountString)


    end

    def tag_search(conn, %{"query" => query}) do

          query = String.trim(query)
          current_user = conn.assigns.current_user
          user_from_cookies = User.find_by_username(cookies(conn, "site"))
          user = user_from_cookies || current_user



          if user == nil do
             real_access = "public"
             user = User.find_by_username("demo")
          else
             real_access = ""
          end
          site = user.username

          if current_user != nil do
            User.increment_number_of_searches(conn.assigns.current_user)
          end

          if real_access == "public" do
            query = "/public " <> query
          end

          queryList = String.split(query)

          if conn.assigns.current_user != nil do
            tag = hd(queryList)
            channel = "#{site}.#{tag}"
            User.update_channel(user,channel)
          end

          Utility.report("CURRENT USER", current_user)

          notes = Search.tag_search(queryList, conn)
          if current_user == nil || user_from_cookies != current_user do
            notes = Enum.filter(notes, fn(x) -> x.public == true end)
          end

          noteCount = length(notes)
          Note.memorize_notes(notes, user.id)

          notes_with_index = Utility.add_index_to_maplist(notes)
          id_string = Note.extract_id_list(notes)

          case noteCount do
            1 -> noteCountString = "1 Note found with tag #{query}"
            _ -> noteCountString = Integer.to_string(noteCount) <> " Notes found with tag #{query}"
          end

          render(conn, "index.html", site: site, notes: notes_with_index, id_string: id_string, noteCountString: noteCountString)

     end


    def raw_random(conn, expected_number_of_entries) do

         IO.puts "RAW RANDOM"
         user = conn.assigns.current_user
         [channel_user_name, channel_name] = user.channel |> String.split(".")
         note_count = Search.count_for_user(user.id)

         cond do
           note_count > 14 ->
              p = (100*expected_number_of_entries) / note_count
              notes = Search.random_notes_for_user(p, user, 7, "none")
           note_count <= 14 ->
              notes = Search.notes_for_user(user, %{"tag" => channel_name, "sort_by" => "created_at", "direction" => "desc"}).notes
         end

         Utility.report("Number of randome notes:", Enum.count(notes))
         Note.memorize_notes(notes, user.id)

         notes = Utility.add_index_to_maplist(notes)
         id_string = Note.extract_id_list(notes)

         case note_count do
           1 -> countReportString =   "1 Random note"
           _ -> countReportString = "#{length(notes)} Random notes"
         end
         render(conn, "index.html", notes: notes, id_string: id_string, noteCountString: countReportString)

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

   def recent(conn, params) do
        User.increment_number_of_searches(conn.assigns.current_user)
        hours_before = String.to_integer params["hours_before"]
        mode = params["mode"]

        user_id = conn.assigns.current_user.id

        case mode do
          "updated" ->
             notes = Search.updated_before_date(hours_before, Timex.now, conn.assigns.current_user)
             update_message = "Recently updated"
          "created" ->
              notes = Search.created_before_date(hours_before, Timex.now, conn.assigns.current_user)
              update_message = "Recently created"
          "viewed" ->
             notes = Search.viewed_before_date(hours_before, Timex.now, conn.assigns.current_user)
             update_message = "Recently viewed"
        end



        note_count = length(notes)
        Note.memorize_notes(notes, conn.assigns.current_user.id)

        notes = Utility.add_index_to_maplist(notes)
        id_string = Note.extract_id_list(notes)

        case note_count do
           1 -> countReportString =   "1 #{update_message} note"
           _ -> countReportString = "#{length(notes)} #{update_message} notes"
        end
        render(conn, "index.html", notes: notes, id_string: id_string, noteCountString: countReportString)
   end


end



