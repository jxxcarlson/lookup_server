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

    ################# tag_search ###############

    defp tag_search_set_user(conn) do

      current_user = conn.assigns.current_user
      qsMap = Utility.qs2map(conn.query_string)
      site = qsMap["site"]
      IO.puts "site = #{site}"
      Utility.report("qsMap", qsMap)

      site_user = User.find_by_username(site)

      if site_user == current_user do
        access = :all
      else
        access = :public
      end

      [site, current_user, site_user, access]
    end

    defp tag_search_set_query_list(query, access) do
        query = String.trim(query)
      if access == :public do
        query = "/public " <> query
      end
      String.split(query)
    end

    defp tag_search_update_channel(conn, site, query_list) do
        if conn.assigns.current_user != nil do
        tag = hd(query_list)
        channel = "#{site}.#{tag}"
        User.update_channel(conn.assigns.current_user, channel)
      end
    end

    def tag_search(conn, %{"query" => query}) do

      Utility.report("tag search query" , query)

      [site, current_user, site_user, access] = tag_search_set_user(conn)

      if current_user != nil do
        User.increment_number_of_searches(current_user)
      end

      query_list = tag_search_set_query_list(query, access)

      # DISABLE THIS FOR NOW
      # tag_search_update_channel(conn, site, query_list)

      # Utility.report("CURRENT USER", current_user.username)
      Utility.report("QUERY LIST", query_list)

      notes = Search.tag_search(query_list, conn)

      # if current_user == nil || site_user != current_user do
      # notes = Enum.filter(notes, fn(x) -> x.public == true end)
      # end

      IO.puts "NOTES FOUND IN TAG_SEARCH: #{length(notes)}"

      noteCount = length(notes)
      if current_user != nil do
        Note.memorize_notes(notes, current_user.id)
      end


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

   def recent(conn, params) do
        User.increment_number_of_searches(conn.assigns.current_user)
        hours_before = String.to_integer params["hours_before"]
        mode = params["mode"]

        user_id = conn.assigns.current_user.id

        case mode do
          "updated" ->
             notes = Search.after_date(:updated, :desc, hours_before, Timex.now, conn.assigns.current_user)
             update_message = "Recently updated"
          "created" ->
              notes = Search.after_date(:created, :desc, hours_before, Timex.now, conn.assigns.current_user)
              update_message = "Recently created"
          "viewed" ->
             notes = Search.after_date(:viewed, :desc, hours_before, Timex.now, conn.assigns.current_user)
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



