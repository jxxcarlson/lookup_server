defmodule LookupPhoenix.Search do
    use LookupPhoenix.Web, :model
    use Ecto.Schema
    import Ecto.Query
    alias LookupPhoenix.Note
    alias LookupPhoenix.User
    alias LookupPhoenix.Repo
    alias LookupPhoenix.Utility
    alias LookupPhoenix.Constant


    def count_for_user(user_id, tag \\ "none") do
      Utility.report("Search.count_for_user, user_id:", user_id)
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
       tag = options["tag"]

       query = Ecto.Query.from note in Note,
         where: note.user_id == ^user_id,
         order_by: [desc: note.inserted_at]

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

       Utility.report("access", access)

       notes = Repo.all(query2) |> filter_public(access)
       original_note_count = length(notes)
       filtered_notes = notes |> filter_random(Constant.random_note_threshold())
       Note.memorize_notes(filtered_notes, user.id)
       %{notes: filtered_notes, note_count: length(filtered_notes), original_note_count: original_note_count}

    end

    def all_notes_for_user(user) do
       query = Ecto.Query.from note in Note,
         where: note.user_id == ^user.id,
         order_by: [desc: note.inserted_at]
       Repo.all(query)
    end

    def all_public_notes_for_user(user) do
      query = Ecto.Query.from note in Note,
        where: note.user_id == ^user.id and note.public == true,
        order_by: [desc: note.inserted_at]
      Repo.all(query)
    end


    def decode_query(query) do
      query
      |> String.downcase
      |> String.replace("/", " /")
      |> String.split(~r/\s/)
    end

    # Input: a list of query terms
    # Output: a pair of lists whose first element consists of tags,
    # the second consists of the remainging elements
    def split_query_terms(query_terms) do
      tags = Enum.filter(query_terms, fn(term) -> String.first(term) == "/" end)
      terms = Enum.filter(query_terms, fn(term) -> String.first(term) != "/" end)
      [tags, terms]
    end

    def basic_query(user_id, access, term, type) do

        query1 = from note in Note, where: note.user_id == ^user_id

        if access == :public do

          query2 = from note in query1, where: note.public == ^ true

        else

          query2 = query1

        end

        if type == :tag do

          query3 = from note in query2, where: ilike(note.tag_string, ^"%#{term}%")

        else

          query3 = from note in query2, where: ilike(note.title, ^"%#{term}%") or ilike(note.tag_string, ^"%#{term}%") or ilike(note.content, ^"%#{term}%")

        end

        query4 = from note in  query3, order_by: [desc: note.inserted_at]

        query4

    end

   def search_with_non_empty_arg(query_terms, user) do

       [access, channel_name, user_id]= User.decode_channel(user)

       [tags, terms] = split_query_terms(query_terms)
       tags = Enum.map(tags, fn(tag) -> String.replace(tag, "/", "") end)


      if !Enum.member?(["all", "public"], channel_name) do
         tags = [channel_name|tags]
      end

     Utility.report("search_with_non_empty_arg, user_id", user_id)

      case tags do
        [] -> query = basic_query(user_id, access, hd(terms), :term)
              terms = tl(terms)

        _ -> query = query = basic_query(user_id, access, hd(tags), :tag)
             tags = tl(tags)

      end

      result = Repo.all(query)
      # |> Note.filter_records_for_user(user_id)
      |> filter_notes_with_tag_list(tags)
      |> filter_records_with_term_list(terms)

      Note.memorize_list(result, user_id)
      Enum.map(result, fn (record) -> record.id end)
      result
    end


    def search(query, user) do
      query_terms = decode_query(query)
      case query_terms do
        [] -> []
        _ -> search_with_non_empty_arg(query_terms, user)
      end
    end

    def tag_search(tag_list, user) do
       IO.puts "HERE IS Search.tag_search"
       [access, channel_name, user_id]= User.decode_channel(user)

       Utility.report("decode_channel:", [access, channel_name, user_id])

       query1 = Ecto.Query.from note in Note,
          where: (note.user_id == ^user_id and ilike(note.tag_string, ^"%#{List.first(tag_list)}%")),
          order_by: [desc: note.updated_at]
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
       result = Repo.all(query3)
    end


    def filter_records_for_user(list, user_id) do
      Enum.filter(list, fn(x) -> x.user_id == user_id end)
    end


    ##################

    def filter_records_with_term(list, term) do

      Enum.filter(list, fn(x) -> String.contains?(String.downcase(x.title), term) or String.contains?(String.downcase(x.content), term) end)

    end


    def filter_records_with_term_list(list, term_list) do

      case {list, term_list} do
        {list,[]} -> list
        {list, term_list} -> filter_records_with_term_list(
              filter_records_with_term(list, hd(term_list)), tl(term_list)
            )
      end

    end

    ################

    def filter_notes_with_tag(note_list, tag) do

       Enum.filter(note_list, fn(note) -> Enum.member?(note.tags, tag) end)

    end


    def filter_notes_with_tag_list(note_list, tag_list) do

      case {note_list, tag_list} do
        {note_list,[]} -> note_list
        {note_list, tag_list} -> filter_notes_with_tag_list(
              filter_notes_with_tag(note_list, hd(tag_list)), tl(tag_list)
            )
      end

    end

    # Get list of random note ids for given user
    def random_notes_for_user(p, user, truncate_at, tag) do
      [access, _channel_name, user_id]= User.decode_channel(user)
      random_ids(p)
      |> Note.getDocumentsFromList
      |> Enum.map(fn(note_record) -> note_record.notes end)
      |> filter_records_for_user(user_id)
      |> filter_public(access)

      |> RandomList.truncateAt(truncate_at)
    end

    # Not used
    def random(p, user_id) do
          {_ok, result} = Ecto.Adapters.SQL.query(Repo, "SELECT id FROM notes TABLESAMPLE BERNOULLI(#{p})")
          id_list = result.rows
          |> List.flatten
          |> Enum.filter(fn(x) -> is_integer(x) end)
          |> RandomList.mcut

          new_id_list = id_list
          |> Note.getDocumentsFromList
          |> Enum.map(fn(note_record) -> note_record.notes end)
          |> filter_records_for_user(user_id)
          Note.memorize_list(new_id_list, user_id)
          new_id_list
     end

    # Get list of random note ids
     def random_ids(p) do
       {_ok, result} = Ecto.Adapters.SQL.query(Repo, "SELECT id FROM notes TABLESAMPLE BERNOULLI(#{p})")
       id_list = result.rows
       |> List.flatten
       |> Enum.filter(fn(x) -> is_integer(x) end)
       |> RandomList.mcut
     end

    # TITLE, note used
    def search_by_title(arg) do
      Ecto.Query.from(p in Note, where: ilike(p.title, ^"%#{List.first(arg)}%"))
      |> Repo.all
    end


    #### DATE-TIME ####

    def viewed_before_date(hours, date_time, user) do
       IO.puts "HO HO HO HO"
       # user_id = user.id
       [access, channel_name, user_id] = User.decode_channel(user)
       then = Timex.shift(date_time, [hours: -hours])
       query1 = Ecto.Query.from note in Note,
          where: note.user_id == ^user_id and note.viewed_at >= ^then,
          order_by: [desc: note.viewed_at]

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

    def updated_before_date(hours, date_time, user) do

       [access, channel_name, user_id] = User.decode_channel(user)
       then = Timex.shift(date_time, [hours: -hours])
       query1 = Ecto.Query.from note in Note,
          where: note.user_id == ^user_id and note.edited_at >= ^then,
          order_by: [desc: note.edited_at]
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

    def created_before_date(hours, date_time, user) do

       [access, channel_name, user_id] = User.decode_channel(user)
       then = Timex.shift(date_time, [hours: -hours])
       query1 = Ecto.Query.from note in Note,
          where: note.user_id == ^user_id and note.inserted_at >= ^then,
          order_by: [desc: note.inserted_at]
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

    #### FILTERS ####

    def filter_random(notes, n) do
      note_count = length(notes)
      if note_count > n do
        RandomList.generate_integers(note_count - 1, 30)
        |> Enum.map(fn(index) -> Enum.at(notes, index) end)
      else
        notes
      end
    end

    def filter_public(list, access) do

      case access do
        :public -> Enum.filter(list, fn(x) -> x.public == true end)
        :nonpublic -> Enum.filter(list, fn(x) -> x.public == false end)
        _ -> list
      end

    end

end

