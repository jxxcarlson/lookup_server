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

    # Used in admin table listing users
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

    def notes_for_channel(channel, options) do

        set_channel(channel, options)

        cond do
         !Enum.member?(Map.keys(options), :access) -> public = true
          options[:access]== :public -> public = true
          options[:access] == :all -> public = false
          true -> public = true
        end

        notes = Note
           |> Note.select_by_channel(channel)
           |> Note.select_public(public)
           |> Repo.all

        original_note_count = length(notes)
        filtered_notes = notes |> filter_random(Constant.random_note_threshold())
        %{notes: filtered_notes, note_count: length(filtered_notes), original_note_count: original_note_count}
   end

    def decode_query(query) do
      query
      |> String.downcase
      |> String.replace("/", " /")
      |> String.split(~r/\s/)
    end

    def search(channel, query, options) do
      query_terms = decode_query(query)
      case query_terms do
        [] -> []
        _ -> search_with_non_empty_arg(channel, query_terms, options)
      end
    end

    # Return notes for user with given tag
    def find_by_user_and_tag(user_id, tag) do
      query = Ecto.Query.from note in Note,
            where: note.user_id == ^user_id,
            where: ^tag in note.tags,
            order_by: [asc: note.inserted_at]
       Repo.all(query)
    end

    # Return N <= max of the user's most recent notes,
    # where the notes are ordered by :viewed, :updated, :created
    def most_recent(scope, order_by, max, user) do
      Note
      |> Note.for_user(user.id)
      |> Note.select_public(scope == :public)
      |> Repo.all
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

   def tag_search(tag_list, conn) do
      user = conn.assigns.current_user
      channel = user.channel
      [channel_name, _] = String.split(channel, ".")

      if Enum.member?(tag_list, "/public") do
        tag_list = tl(tag_list)
      end

      # query_for_tag_search(user_id, tag_list, channel_name, access)
      Note
      |> Note.select_by_channel(channel)
      |> Note.select_by_tag(tag_list)
      |> Note.select_public(channel_name == user.username)
      |> Note.sort_by_viewed_at
      |> Repo.all
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

    defp filter_random(notes, n) do
      note_count = length(notes)
      if note_count > n do
        RandomList.generate_integers(note_count - 1, 30)
        |> Enum.map(fn(index) -> Enum.at(notes, index) end)
      else
        notes
      end
    end


end

