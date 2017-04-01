defmodule LookupPhoenix.Search do
    use LookupPhoenix.Web, :model
    use Ecto.Schema

    import Ecto.Query
    alias LookupPhoenix.Note
    alias LookupPhoenix.NoteSearch
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

        IO.puts "In notes_for_channel, channel = #{channel}"

        notes = Note
           |> NoteSearch.select_by_channel(channel)
           |> NoteSearch.select_public(public)
           |> NoteSearch.sort_by_viewed_at
           |> Repo.all
           |> NoteSearch.most_recent(20)

        IO.puts "Search, notes_for_channel, notes found: #{length(notes)}"

        original_note_count = length(notes)
        filtered_notes = notes |> filter_random(Constant.random_note_threshold())
       IO.puts "Search, notes_for_channel, filtered notes found: #{length(filtered_notes)}"

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
      Utility.report("query_terms", query_terms)
      case query_terms do
        [] -> []
        _ -> do_search(channel, query_terms, options)
      end
    end

    # Return N <= max of the user's most recent notes,
    # where the notes are ordered by :viewed, :updated, :created
    def most_recent(scope, order_by, max, user) do
      Note
      |> NoteSearch.for_user(user.id)
      |> NoteSearch.select_public(scope == :public)
      |> Repo.all
      |> Enum.slice(0..max)
    end

    defp cookies(conn, cookie_name) do
       conn.cookies[cookie_name]
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

   # access = :public, :all
   def tag_search(tag_list, channel, access) do

      [channel_name, _] = String.split(channel, ".")

      if Enum.member?(tag_list, "/public") do
        tag_list = tl(tag_list)
      end

      Note
      |> NoteSearch.select_by_channel(channel)
      |> NoteSearch.select_by_tag(tag_list)
      |> NoteSearch.select_public(access == :public)
      |> NoteSearch.sort_by_viewed_at
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

    defp first_query(channel, access, term, type) do

        [channel_name, channel_tag] = String.split(channel, ".")
        channel_id = User.find_by_username(channel_name).id
        if channel_tag == "public" do access = :public end

        query = Note
        |> NoteSearch.select_by_channel(channel)
        |> NoteSearch.select_public(access == :public)
        |> NoteSearch.select_by_tag(term, type == :tag)
        |> NoteSearch.select_by_term(term, type == :term)
        |> NoteSearch.full_text_search(term, type == :text)
        |> NoteSearch.sort_by_viewed_at

    end

   defp do_search(channel, query_terms, options) do

       cond do
         !Enum.member?(Map.keys(options), :access) ->
           access = %{access: :public}
         true ->
           access = options.access
       end

       [tags, terms] = split_query_terms(query_terms)
       tags = Enum.map(tags, fn(tag) -> String.replace(tag, "/", "") end)
       if Enum.member?(tags, "public") do
         tags = List.delete(tags, "public")
         access = %{access: :public}
       end
       search_options = Enum.filter(terms, fn(term) -> String.starts_with?(term, "-") end) || []
       terms = Enum.filter(terms, fn(term) -> !String.starts_with?(term, "-") end)

       Utility.report("  -- tags", tags)
       Utility.report("  -- terms", terms)

       cond do
         Enum.member?(search_options, "-t") -> type = :text
         tags != [ ] -> type = :tag
         true -> type = :term
       end

       case tags do
         [] -> query = first_query(channel, access, hd(terms), type)
              terms = tl(terms)

         _ -> query = query = first_query(channel, access, hd(tags), type)
             tags = tl(tags)
       end

      result = Repo.all(query)
        |> filter_notes_with_tag_list(tags)
        |> filter_records_with_term_list(terms)

    end

    ################## FILTERS #################

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

