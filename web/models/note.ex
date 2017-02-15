defmodule LookupPhoenix.Note do
  use LookupPhoenix.Web, :model

  use Ecto.Schema
  import Ecto.Query
  alias LookupPhoenix.Note
  alias LookupPhoenix.User
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility

  schema "notes" do
    use Timex.Ecto.Timestamps

    field :title, :string
    field :content, :string
    # field :user_id, :integer
    field :viewed_at, :utc_datetime
    field :edited_at, :utc_datetime
    field :tag_string, :string
    field :tags, {:array, :string}
    field :public, :boolean

     belongs_to :user, LookupPhoenix.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :content, :tags, :user_id, :viewed_at, :edited_at, :tag_string, :public])
    |> validate_required([:title, :content])
  end


    def search_by_title(arg) do
      Ecto.Query.from(p in Note, where: ilike(p.title, ^"%#{List.first(arg)}%"))
      |> Repo.all
    end

    ####
    def updated_before_date(hours, date_time, user) do

       [access, channel_name, user_id] = decode_channel(user)
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

       [access, channel_name, user_id] = decode_channel(user)
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

    def viewed_before_date(hours, date_time, user) do
       IO.puts "HO HO HO HO"
       # user_id = user.id
       [access, channel_name, user_id] = decode_channel(user)
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
    ###

    def count_for_user(user_id, tag \\ "none") do
      Utility.report("Note.count_for_user, user_id:", user_id)
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

    def notes_for_user(user_id, options) do
       tag = options["tag"]
       query = Ecto.Query.from note in Note,
         where: note.user_id == ^user_id,
         order_by: [desc: note.inserted_at]
       if Enum.member?(["none"], tag) do
          query2 = query
       else
        query2 = from note in query, where: ilike(note.tag_string, ^"%#{tag}%")
      end
       Repo.all(query2)
       #|> getDocumentsFromList
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

    def decode_channel(user) do
        user_id = user.id
        access = :none

        [channel_user_name, channel_name] = String.split(user.channel, ".")

        if channel_user_name == user.username do
          access = :all
          user_id = user.id
        else
          channel_user = User.find_by_username(channel_user_name)
          if channel_user == nil do
            user_id = 0
          else
            user_id = channel_user.id
          end
          access = :public
        end

        [access, channel_name, user_id]
    end

    def search_with_non_empty_arg(query_terms, user) do

       [access, channel_name, user_id]= decode_channel(user)

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
      |> Note.filter_notes_with_tag_list(tags)
      |> Note.filter_records_with_term_list(terms)

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
       IO.puts "HERE IS NOTE.TAG_SEARCH"
       [access, channel_name, user_id]= decode_channel(user)

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


    def filter_public(list,access) do
      if access == :public do
        Enum.filter(list, fn(x) -> x.public == true end)
       else
         list
       end
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

   ################

     def extract_id_list(list) do
       list |> Enum.map(fn(note) -> note.id end) |> Enum.join(",")
     end

     def previous(note, notes) do
       index = note.index
       previous_index = max(0, index - 1)
       previous_note = Enum.at(notes, previous_index)
       previous_note.id
     end

     def next(note, notes) do
        index = note.index
        next_index = min(length(notes)-1, index + 1)
        next_note = Enum.at(notes, next_index)
        next_note.id
     end

     def fromPair(pair) do
          # %Note{ :title => pair[0], :content => pair[1]}
          %Note{ :title => "Foo", :content => "Bar"}
     end

     def count do
       Repo.aggregate(Note, :count, :id)
     end

    def getDocumentsFromList(id_list) do
      id_list |> Enum.map(fn(id) -> Repo.get!(Note, id) end)
    end

    # Get list of random note ids
    def random_ids(p) do
      {_ok, result} = Ecto.Adapters.SQL.query(Repo, "SELECT id FROM notes TABLESAMPLE BERNOULLI(#{p})")
      id_list = result.rows
      |> List.flatten
      |> Enum.filter(fn(x) -> is_integer(x) end)
      |> ListUtil.mcut
    end

    # Get list of random note ids for given user
    def random_notes_for_user(p, user, truncate_at, tag) do
      [access, _channel_name, user_id]= decode_channel(user)
      random_ids(p)
      |> getDocumentsFromList
      |> filter_records_for_user(user_id)
      |> filter_public(access)

      |> ListUtil.truncateAt(truncate_at)
    end

    def random(p, user_id) do
          {_ok, result} = Ecto.Adapters.SQL.query(Repo, "SELECT id FROM notes TABLESAMPLE BERNOULLI(#{p})")
          id_list = result.rows
          |> List.flatten
          |> Enum.filter(fn(x) -> is_integer(x) end)
          |> ListUtil.mcut

          new_id_list = id_list
          |> getDocumentsFromList
          |> filter_records_for_user(user_id)
          Note.memorize_list(new_id_list, user_id)
          new_id_list
     end

    def identity(text) do
      text
    end

#########

    def memorize_notes(note_list, user_id) do
      note_list
      |> Enum.map(fn(note) -> note.id end)
      |> memorize_list(user_id)
    end

    def memorize_list(id_list, user_id) do
      new_id_list = Enum.filter(id_list, fn x -> is_integer(x) end)
      Mnemonix.put(Cache, "active_notes_#{user_id}", new_id_list)
    end

    def recall_list(user_id) do
      recalled = Mnemonix.get(Cache, "active_notes_#{user_id}")
      if recalled == nil do
         []
      else
         recalled |> Enum.filter(fn x -> is_integer(x) end)
      end
    end


  def update_viewed_at(note) do
    params = %{"viewed_at" => Timex.now}
    changeset = Note.changeset(note, params)
    Repo.update(changeset)
  end

  def update_edited_at(note) do
      params = %{"edited_at" => Timex.now}
      changeset = Note.changeset(note, params)
      Repo.update(changeset)
  end



   def inserted_at(note) do
     {:ok, inserted_at }= note.inserted_at |> Timex.local |> Timex.format("{Mfull} {D}, {YYYY}")
     inserted_at
   end

   def inserted_at_short(note) do
      {:ok, inserted_at }= note.inserted_at |> Timex.local |> Timex.format("{M}/{D}/{YYYY}")
      inserted_at
   end

   def tags2string(note) do
     note.tags
     |> Enum.join(", ")
   end


   ########

   def decode_query_string(q_string) do


      # Example: q_string=index=4&id_list=35%2C511%2C142%2C525%2C522%2C531%2C233
      query_data = q_string|> Utility.parse_query_string

      # Get inputs
      index = query_data["index"]; {index, _} = Integer.parse index
      id_string = query_data["id_string"] |> String.replace("%2C", ",")
      id_list = String.split(id_string, ",")
      channel = query_data["channel"]

     # Compute outputs
      current_id = Enum.at(id_list, index)
      note_count = length(id_list)
      last_index = note_count - 1

      if index >= last_index do
        next_index = 0
      else
        next_index = index + 1
      end
      if index == 0 do
        previous_index = last_index
      else
        previous_index = index - 1
      end

      last_id = Enum.at(id_list, last_index)
      next_id = Enum.at(id_list, next_index)
      previous_id = Enum.at(id_list, previous_index)
      first_id = Enum.at(id_list, 0)

      # Assemble output
      output = %{first_index: 0, index: index, last_index: last_index,
        previous_index: previous_index, next_index: next_index,
        first_id: first_id, last_id: last_id,
        previous_id: previous_id, current_id: current_id, next_id: next_id,
        id_string: id_string, id_list: id_list,
        note_count: note_count, channel: channel}

      output
   end

   ## ONE-TIME ##

   def init_viewed_at(note) do
         then = Timex.shift(Timex.now, [hours: -30])
         params = %{"viewed_at" => then}
         changeset = Note.changeset(note, params)
         Repo.update(changeset)
     end

     def init_edited_at(note) do
           then = Timex.shift(Timex.now, [hours: -170])
           params = %{"edited_at" => then}
           changeset = Note.changeset(note, params)
           Repo.update(changeset)
      end


     def init_updated_at(note) do
         then = Timex.shift(Timex.now, [hours: -171])
         params = %{"updated_at" => then}
         changeset = Note.changeset(note, params)
         Repo.update(changeset)
     end

     def init_notes_viewed_at do
       Note |> Repo.all |> Enum.map(fn(note) -> Note.init_viewed_at(note) end)
     end

      def init_notes_edited_at do
         Note |> Repo.all |> Enum.map(fn(note) -> Note.init_edited_at(note) end)
      end


    def set_public(note, value) do
      params = %{"public" => value}
        changeset = Note.changeset(note, params)
      Repo.update(changeset)
    end

    def init_all_public(value) do
       Note |> Repo.all |> Enum.map(fn(note) -> Note.set_public(note, value) end)
    end

     def set_public_for_user(user_id, value) do
        options = %{}
        notes_for_user(user_id, options )|> Enum.map(fn(note) -> Note.set_public(note, value) end)
     end

    def erase_string(note, str) do
       new_conent = String.replace(note.content, str, "")
       params = %{"content" => new_conent}
       changeset = Note.changeset(note, params)
       Repo.update(changeset)
    end

    def public_indicator(note) do
      if note.public do
        "Public"
      else
        "Private"
      end
    end

    def toggle_public(note) do
      public = !note.public
      params = %{"public" => public}
      changeset = Note.changeset(note, params)
      Repo.update(changeset)
    end

    ## test
    def erase_string_in_all_notes(str) do
         Note |> Repo.all |> Enum.map(fn(note) -> Note.erase_string(note, str) end)
     end

end

