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
          channel_tag = "public"
          channel = channel_user <> "." <> channel_tag
          user = channel_user
        else
          user = current_user
          channel = user.channel
          User.increment_number_of_searches(user)
        end

        user_signed_in = current_user != nil
        notes = Search.search(channel, query, %{user_signed_in: user_signed_in})
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

    defp tag_search_set_query_list(query, access) do
        query = String.trim(query)
      if access == :public do
        query = "/public " <> query
      end
      String.split(query)
    end

    # Used in tag links in tag index page
    def tag_search(conn, %{"query" => query}) do

      qsMap = Utility.qs2map(conn.query_string)
      qsKeys = Map.keys(qsMap)
      site = qsMap["site"]
      current_user = conn.assigns.current_user

      # set access
      cond do
        current_user == nil ->
          access = :public
        current_user.username == site ->
          access = :all
        true ->
          access = :public
      end

      if current_user != nil do
        User.increment_number_of_searches(current_user)
      end

      # Add /public if access = :public
      query_list = tag_search_set_query_list(query, access)
      notes = Search.tag_search(query_list, conn)

      # if current_user == nil || site_user != current_user do
      # notes = Enum.filter(notes, fn(x) -> x.public == true end)
      # end

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

      if access == :all do
        render(conn, "index.html", site: site, notes: notes_with_index, id_string: id_string, noteCountString: noteCountString)
      else
        render(conn, "index.html", site: site, notes: notes_with_index, id_string: id_string, noteCountString: noteCountString)
        # redirect(conn, to: "/site/#{site}", notes: notes)
      end
     end




   # Route: /recent?QUERY, where
   # QUERY is hourse_before=N&mode=MODE, where
   # MODE = upated | created | viewed
   def recent(conn, params) do
        parameter = params["username"]
        IO.puts "RECENT: USERNAME = #{parameter}"

        if parameter =~ ~r/\./ do
          [username, tag] = String.split(parameter, "\.")
        else
          username = parameter
          tag = "all"
        end

        channel = username <> "." <> tag

        user = User.find_by_username(username)
        current_user = conn.assigns.current_user
        public = !(user.id == current_user.id)

       IO.puts "In Search Controller, recent, user = #{user.username} = current user = #{current_user.username}"

        IO.puts "In Search Controller, recent, public = #{public}"

        query_string_map = Utility.qs2map(conn.query_string)
        User.increment_number_of_searches(current_user)

        mode = String.to_atom(query_string_map["mode"])
        user_id = user.id

        update_message = "Recently #{mode}"

        cond do
          "hours_before" in Map.keys(query_string_map) ->
             hours_before = String.to_integer query_string_map["hours_before"]
             notes = Note
               |> Note.select_by_channel(channel)
               |> Note.select_by_viewed_at_hours_ago(25)
               |> Note.select_public(public)
               |> Note.sort_by_viewed_at
               |> Repo.all
          "max" in Map.keys(query_string_map) ->
             max_notes = String.to_integer query_string_map["max"]
             notes = Note
              |> Note.select_by_channel(channel)
              |> Note.select_public(public)
              |> Note.sort_by_viewed_at
              |> Repo.all
              |> Note.most_recent(20)
          true ->
             notes = Note
              |> Note.select_by_channel("#{current_user.username}.all")
              |> Note.select_public(true)
              |> Note.sort_by_viewed_at
              |> Repo.all
              |> Note.most_recent(5)
        end

        note_count = length(notes)
        Note.memorize_notes(notes, conn.assigns.current_user.id)

        notes = Utility.add_index_to_maplist(notes)
        id_string = Note.extract_id_list(notes)
        case note_count do
           1 -> countReportString =   "1 #{update_message} note"
           _ -> countReportString = "#{length(notes)} #{update_message} notes"
        end
        id_string = Note.extract_id_list(notes)
        render(conn, "index.html", notes: notes, id_string: id_string, noteCountString: countReportString)
   end


end



