defmodule LookupPhoenix.Search do
    use LookupPhoenix.Web, :model
    use Ecto.Schema
    import Ecto.Query
    alias LookupPhoenix.Note
    alias LookupPhoenix.User
    alias LookupPhoenix.Repo
    alias LookupPhoenix.Utility
    alias LookupPhoenix.Constant

    ########### PUBLIC INTERFACE ######################

    def count_for_user(user_id, tag \\ "none") do
      query = Ecto.Query.from note in Note,
         select: note.id,
         where: note.user_id == ^user_id
      if Enum.member?(["none"], tag) do
        query2 = query
      else
        query2 = from note in query, where: ilike(note.tag_string, ^"%#{tag}%")
      end
      length Repo.all(query2)
    end


    def notes_for_user(user, options) do
       [access, channel_name, user_id] = User.decode_channel(user)
       options = ensure_random_is_set(user, user_id, options)
       Utility.report("Search, notes_for_user options", options)
       tag = options["tag"]

       query = initial_query(user, user_id) |> second_query(channel_name)
       notes = Repo.all(query) |> filter_public(access)
       original_note_count = length(notes)
       # Apply random filter if the set of found note is too large, unless countermanded
       filtered_notes = filter_notes(notes, options)

       Note.memorize_notes(filtered_notes, user.id)
       %{notes: filtered_notes, note_count: length(filtered_notes), original_note_count: original_note_count}
    end

    def notes_for_channel(channel, options) do
        IO.puts "HERE IS: search.ex, notes_for_channel with CHANNEL = #{channel}"
        Utility.report("OPTIONS (NFC)", options)
        # [channel_user, channel_user_name, channel_name] =
        set_channel(channel, options)

        cond do
         !Enum.member?(Map.keys(options), :access) -> public = true
          options[:access]== :public -> public = true
          options[:access] == :all -> public = false
          true -> public = true
        end

        IO.puts "NFC, public = #{public}"

        notes = Note
           |> Note.select_by_channel(channel)
           |> Note.select_public(public)
           |> Repo.all

        original_note_count = length(notes)
        filtered_notes = notes |> filter_random(Constant.random_note_threshold())
        ## Note.memorize_notes(filtered_notes, channel_user.id)
        # NOTE RECORD:
        %{notes: filtered_notes, note_count: length(filtered_notes), original_note_count: original_note_count}
   end

   # scope = :all|:public
    def all_notes_for_user(scope, order, order_by, user) do
       IO.puts "SEARCH, ALL NOTES FOR USER, ORDER_BY = #{order_by}"
       case scope do
         :all -> query = Ecto.Query.from note in Note,
                      where: note.user_id == ^user.id
         :public -> query = Ecto.Query.from note in Note,
                      where: note.user_id == ^user.id and note.public == true
       end
       cond do
         order_by == :created and order == :desc ->
           query2 = from note in query,
                      order_by: [desc: note.inserted_at]
         order_by == :created and order == :asc ->
           query2 = from note in query,
                      order_by: [asc: note.inserted_at]
         order_by == :updated and order == :desc ->
            query2 = from note in query,
                       order_by: [desc: note.updated_at]
         order_by == :updated and order == :asc ->
            query2 = from note in query,
                       order_by: [asc: note.updated_at]
         order_by == :viewed and order == :desc ->
           query2 = from note in query,
                      order_by: [desc: note.viewed_at]
         order_by == :viewed and order == :asc ->
           query2 = from note in query,
                      order_by: [asc: note.viewed_at]
         true ->
           query2 = from note in query,
                      order_by: [desc: note.viewed_at]
       end

       Repo.all(query2)
    end

    def decode_query(query) do
      query
      |> String.downcase
      |> String.replace("/", " /")
      |> String.split(~r/\s/)
    end

    def search(channel, query, options) do

      case query  do
        nil -> IO.puts "NIL qery string"
        "" -> IO.puts "Empty query string"
        _ -> Utility.report("Search.search, query", query)
      end

      # for testing: query = "code"
      query_terms = decode_query(query)

      case query_terms do
        [] -> []
        _ -> search_with_non_empty_arg(channel, query_terms, options)
      end
    end

    def tag_search(tag_list, conn) do
      [access, channel_name, user_id] = setup_for_tag_search(conn)

      if Enum.member?(tag_list, "/public") do
        tag_list = tl(tag_list)
      end

      query_for_tag_search(user_id, tag_list, channel_name, access)
      |> Repo.all
    end

    # Return notes for user with given tag
    def find_by_user_and_tag(user_id, tag) do
      query = Ecto.Query.from note in Note,
            where: note.user_id == ^user_id,
            where: ^tag in note.tags,
            order_by: [asc: note.inserted_at]
       Repo.all(query)
    end


   # Get list of random note ids for given user
    def random_notes_for_user(p, user, truncate_at, tag) do
      [access, _channel_name, user_id]= User.decode_channel(user)
      random_ids(p)
      |> Note.getDocumentsFromList(%{random_display: true})
      |> Enum.map(fn(note_record) -> note_record.notes end)
      |> filter_records_for_user(user_id)
      |> filter_public(access)

      |> RandomList.truncateAt(truncate_at)
    end

    # Return the user's notes that are viewed, updated, or created after
    # date_time.  query type = :viewed, :updated, :created
    # order = :asc | :desc
    def after_date(query_type, order, hours, date_time, user) do
       [access, channel_name, user_id] = User.decode_channel(user)

       query = set_query_for_channel_search(user, channel_name, access)

       then = Timex.shift(date_time, [hours: -hours])
       query1 = after_date_query(query_type, order, user_id, then)

        if Enum.member?(["all", "public"], channel_name)  do
          query2 = query1
        else
          query2 = from note in query1,
            where: ilike(note.tag_string, ^"%#{channel_name}%")
        end
        case access do
           :all -> query3 = query2
           :public -> query3 = from note in query2, where: note.public == ^true
        end

        if access == :none do
           []
        else
           Repo.all(query3)
        end
    end

    # Return N <= max of the user's most recent notes,
    # where the notes are ordered by :viewed, :updated, :created
    def most_recent(scope, order_by, max, user) do
      all_notes_for_user(scope, :desc, order_by, user)
      |> Enum.slice(0..max)
    end

   def getDocumentsFromList(id_list, options \\ %{}) do
      notes = id_list |> Enum.map(fn(id) -> Repo.get!(Note, id) end)
      if options.random_display == true do
        notes = notes |> filter_random(Constant.random_note_threshold())
      end
      %{notes: notes, note_count: length(notes), original_note_count: length(id_list)}
    end

############### PRIVATE FUNCTIONS ##########################

    defp cookies(conn, cookie_name) do
       conn.cookies[cookie_name]
    end

   ############### notes_for_user ##########################

    defp ensure_random_is_set(user, user_id, options) do
       if Enum.member?(Map.keys(options), "random") do
         IO.puts "Search, notes_for_user, key random exists"
       else
         IO.puts "Search, notes_for_user, key random does NOT exist"
         # Do not randomize notes if there is a defined sort order preference
         if User.get_preference(user, "sort_by") == "idx" do
           options = Map.merge(options, %{random: false})
         else
           # This weird? WTF?
           options = Map.merge(options, %{random: false})
         end
       end
       options
    end

    defp initial_query(user, user_id) do
      cond do
               User.get_preference(user, "sort_by") == "idx" ->
                  IO.puts "SORT BY IDX"
                  query = Ecto.Query.from note in Note,
                          where: note.user_id == ^user_id,
                          order_by: [asc: note.idx]
               true ->
                 IO.puts "SORT BY CREATION DATE"
                 query = Ecto.Query.from note in Note,
                          where: note.user_id == ^user_id,
                          order_by: [desc: note.inserted_at]
             end
    end

    defp second_query(query, channel_name) do

        case channel_name do
         "all" -> query2 = query
         "public" -> query2 = query
         "nonpublic" -> query2 = query
         "notag" ->
             query2 = from note in query,
               where: is_nil(note.tag_string) or note.tag_string == ""
         _ ->
             query2 = from note in query,
               where: ilike(note.tag_string, ^"%#{channel_name}%")
       end

    end

    defp filter_notes(notes, options) do
       cond do
         options.random == true ->
            filtered_notes = notes |> filter_random(Constant.random_note_threshold())
         options.random == false ->
            filtered_notes = notes
          true ->
            filtered_notes = notes
       end
    end

    defp filter_records_for_user(list, user_id) do
      Enum.filter(list, fn(x) -> x.user_id == user_id end)
    end

    ############ NOTES FOR CHANNEL ######

    defp set_channel(channel, options) do
      [channel_user_name, channel_name] = String.split(channel, ".")

      if channel_user_name == nil do
        channel_user = User.find_by_username("demo")
        channel_name = "public"
      else
        channel_user = User.find_by_username(channel_user_name)
      end

      # Let tag, if present, take precedence over chanel_name
      tag = options["tag"]
      channel_name = tag || channel_name
      [channel_user, channel_user_name, channel_name]
    end


    defp set_query_for_channel_search(user, channel_name, access) do
        if User.get_preference(user, "sort_by") == "idx" do
            query = Ecto.Query.from note in Note,
               where: note.user_id == ^user.id,
               order_by: [asc: note.idx]
        else
            query = Ecto.Query.from note in Note,
               where: note.user_id == ^user.id,
               order_by: [desc: note.inserted_at]
        end

        if access == :public do
          query2 = from note in query, where: note.public == true
        else
          query2 = query
        end

        if !Enum.member?(["public", "all"], channel_name) do
          IO.puts "SELECTING NOTES IN CHANNEL"
          query3 = from note in query2, where: ilike(note.tag_string, ^"%#{channel_name}%")
        else
          IO.puts "IGNORING CHANNEL"
          query3 = query2
        end
    end

    ############ TAG SEARCH ##########

    defp setup_for_tag_search(conn) do
      if conn.assigns.current_user == nil do
        real_access = :public
        channel_user_name = cookies(conn, "site")
        user = User.find_by_username(channel_user_name)
        if user == nil do
         user = User.find_by_username("demo")
        end
      else
        user = conn.assigns.current_user
      end

      [access, channel_name, user_id] = User.decode_channel(user)
      access = real_access || access
      [access, channel_name, user_id]
    end

    defp query_for_tag_search(user_id, tag_list, channel_name, access) do
      query1 = Ecto.Query.from note in Note,
        where: note.user_id == ^user_id,
        where: ilike(note.tag_string, ^"%#{hd(tag_list)}%"),
        order_by: [desc: note.updated_at]

      if Enum.member?(["all", "public"], channel_name)  do
         query2 = query1
      else
         query2 = from note in query1, where: ^channel_name in note.tags
         # query2 = from note in query1, where: ilike(note.tag_string, ^"%#{channel_name}%")

      end

      case access do
          :all -> query3 = query2
          :public -> query3 = from note in query2, where: note.public == ^true
      end
      query3
    end

    #### DATE-TIME ####

    defp after_date_query(query_type, order, user_id, then) do

      case {query_type, order} do
        {:viewed, :asc} ->
          query  = Ecto.Query.from note in Note,
            where: note.user_id == ^user_id and note.viewed_at >= ^then,
            order_by: [asc: note.viewed_at]
        {:viewed, :desc} ->
          query  = Ecto.Query.from note in Note,
            where: note.user_id == ^user_id and note.viewed_at >= ^then,
            order_by: [desc: note.viewed_at]

        {:updated, :asc} ->
           query  = Ecto.Query.from note in Note,
             where: note.user_id == ^user_id and note.updated_at >= ^then,
             order_by: [asc: note.updated_at]
        {:updated, :desc} ->
           query  = Ecto.Query.from note in Note,
             where: note.user_id == ^user_id and note.updated_at >= ^then,
             order_by: [desc: note.updated_at]

        {:created, :asc} ->
           query  = Ecto.Query.from note in Note,
             where: note.user_id == ^user_id and note.inserted_at >= ^then,
             order_by: [asc: note.inserted_at]
        {:created, :desc} ->
           query  = Ecto.Query.from note in Note,
             where: note.user_id == ^user_id and note.inserted_at >= ^then,
             order_by: [desc: note.inserted_at]
        end
    end

    ##################################


    # Input: a list of query terms
    # Output: a pair of lists whose first element consists of tags,
    # the second consists of the remainging elements
    defp split_query_terms(query_terms) do
      tags = Enum.filter(query_terms, fn(term) -> String.first(term) == "/" end)
      |> Enum.filter(fn(term) -> term != "" end)
      terms = Enum.filter(query_terms, fn(term) -> String.first(term) != "/" end)
      |> Enum.filter(fn(term) -> term != "" end)
      [tags, terms]
    end

    defp basic_query(channel, access, term, type) do

        [channel_name, channel_tag] = String.split(channel, ".")
        channel_id = User.find_by_username(channel_name).id

        if Enum.member?(["all", "public"], channel_tag) do
          query1 = from note in Note,
            where: note.user_id == ^channel_id
        else
          query1 = from note in Note,
            where: note.user_id == ^channel_id and ilike(note.tag_string, ^"%#{channel_tag}%")
        end


        #############################################

        if access == :public or channel_tag == "public" do

          query2 = from note in query1, where: note.public == true

        else

          query2 = query1

        end


        case type do

          :tag -> query3 = from note in query2, where: ilike(note.tag_string, ^"%#{term}%")
          :text -> query3 = from note in query2, where: ilike(note.title, ^"%#{term}%") or ilike(note.tag_string, ^"%#{term}%") or ilike(note.content, ^"%#{term}%")
          _ ->   query3 = from note in query2, where: ilike(note.title, ^"%#{term}%") or ilike(note.tag_string, ^"%#{term}%")

        end

        #############################################

        query4 = from note in  query3, order_by: [desc: note.inserted_at]

        query4

    end

   defp search_with_non_empty_arg(channel, query_terms, options) do

       Utility.report("search_with_non_empty_arg: INPUTS", [channel, query_terms, options])

       cond do
         !Enum.member?(Map.keys(options), :access) ->
           access = %{access: :public}
         true ->
           access = options.access
       end

       Utility.report("access", access)

       [tags, terms] = split_query_terms(query_terms)
       tags = Enum.map(tags, fn(tag) -> String.replace(tag, "/", "") end)
       search_options = Enum.filter(terms, fn(term) -> String.starts_with?(term, "-") end) || []
       terms = Enum.filter(terms, fn(term) -> !String.starts_with?(term, "-") end)

       cond do
         Enum.member?(search_options, "-t") -> type = :text
         tags != [ ] -> type = :tag
         true -> type = :standard
       end

       Utility.report("0. tags", tags)

       case tags do
         [] -> query = basic_query(channel, access, hd(terms), type)
              terms = tl(terms)
              IO.puts("BRANCH 1")

         _ -> query = query = basic_query(channel, access, hd(tags), type)
             tags = tl(tags)
             IO.puts("BRANCH 2")
       end

     Utility.report("1. query", query)
     Utility.report("2. terms", terms)
     Utility.report("3. tags", tags)

      result = Repo.all(query)
        |> filter_notes_with_tag_list(tags)
        |> filter_records_with_term_list(terms)

    end



    ##################

    defp filter_records_with_term(list, term) do

      Utility.report("XXX: filter_records_with_term", [length(list),term])
      Enum.map(list, fn(x) -> IO.puts("#{x.id}, #{x.title}, ts: #{x.tag_string}")end )
      Enum.filter(list, fn(x) -> String.contains?(String.downcase(x.title), term) or String.contains?(x.tag_string, term) or String.contains?(String.downcase(x.content), term) end)

    end


    defp filter_records_with_term_list(list, term_list) do

        info = {Enum.map(list, fn(x) -> "#{x.id}: #{x.title}, #{x.tag_string}" end), term_list}
        Utility.report("XX: filter_records_with_term_list", info)

      case {list, term_list} do
        {list,[]} -> list
        {list, term_list} -> filter_records_with_term_list(
              filter_records_with_term(list, hd(term_list)), tl(term_list)
            )
      end

    end

    ################

    defp filter_notes_with_tag(note_list, tag) do

       Enum.filter(note_list, fn(note) -> Enum.member?(note.tags, tag) end)

    end


    defp filter_notes_with_tag_list(note_list, tag_list) do

      case {note_list, tag_list} do
        {note_list,[]} -> note_list
        {note_list, tag_list} -> filter_notes_with_tag_list(
              filter_notes_with_tag(note_list, hd(tag_list)), tl(tag_list)
            )
      end

    end


    # Not used
    defp random(p, user_id) do
          {_ok, result} = Ecto.Adapters.SQL.query(Repo, "SELECT id FROM notes TABLESAMPLE BERNOULLI(#{p})")
          id_list = result.rows
          |> List.flatten
          |> Enum.filter(fn(x) -> is_integer(x) end)
          |> RandomList.mcut

          new_id_list = id_list
          |> Note.getDocumentsFromList(%{random_display: true})
          |> Enum.map(fn(note_record) -> note_record.notes end)
          |> filter_records_for_user(user_id)
          Note.memorize_list(new_id_list, user_id)
          new_id_list
     end

    # Get list of random note ids
     defp random_ids(p) do
       {_ok, result} = Ecto.Adapters.SQL.query(Repo, "SELECT id FROM notes TABLESAMPLE BERNOULLI(#{p})")
       id_list = result.rows
       |> List.flatten
       |> Enum.filter(fn(x) -> is_integer(x) end)
       |> RandomList.mcut
     end

    # TITLE, note used
    defp search_by_title(arg) do
      Ecto.Query.from(p in Note, where: ilike(p.title, ^"%#{List.first(arg)}%"))
      |> Repo.all
    end




    #### FILTERS ####

    defp filter_random(notes, n) do
      note_count = length(notes)
      if note_count > n do
        RandomList.generate_integers(note_count - 1, 30)
        |> Enum.map(fn(index) -> Enum.at(notes, index) end)
      else
        notes
      end
    end

    defp filter_public(list, access) do

      case access do
        :public -> Enum.filter(list, fn(x) -> x.public == true end)
        :nonpublic -> Enum.filter(list, fn(x) -> x.public == false end)
        _ -> list
      end

    end


end

