defmodule LookupPhoenix.Note do
  use LookupPhoenix.Web, :model
  use Timex

  use Ecto.Schema
  import Ecto.Query
  alias LookupPhoenix.Note
  alias LookupPhoenix.User
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility
  alias LookupPhoenix.Constant
  alias LookupPhoenix.Identifier

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
    field :shared, :boolean
    field :tokens, {:array, :map}
    field :idx, :integer
    field :identifier, :string

     belongs_to :user, LookupPhoenix.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :content, :tags, :user_id, :viewed_at,
       :edited_at, :tag_string, :public, :shared, :tokens, :idx, :identifier])
    |> unique_constraint(:identifier)
    |> validate_required([:title, :content])
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

    def identity(text) do
      text
    end

#########

    def memorize_notes(note_list, user_id) do
      note_list
      |> Enum.map(fn(note) -> note.id end)
      |> memorize_list(user_id)
      note_list
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

   # note.updated_at |> Timex.local |> Timex.format("{M}-{D}-{YYYY}")

    def updated_at_short(note) do
      {:ok, updated_at }= note.updated_at |> Timex.local |> Timex.format("{M}/{D}/{YYYY}")
      updated_at
   end

   def tags2string(note) do
     note.tags
     |> Enum.join(", ")
   end


   ########

   def decode_query_string(q_string) do

      IO.puts "QUERY STRING: #{q_string}"
      # Example: q_string=index=4&id_list=35%2C511%2C142%2C525%2C522%2C531%2C233
      query_data = q_string|> Utility.parse_query_string

      # Get inputs
      IO.puts "QUERY DATA[INDEX] = " <> query_data["index"]
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


    def notes_for_user(user_id, option \\ "none") do
      query = Ecto.Query.from note in Note,
        select: note.id,
        where: note.user_id == ^user_id
      if option == "public" do
        query2 = from  note in query,
          where: note.public == true
      else
        query2 = query
      end
      Repo.all(query2)
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


    # Utility.generate_time_limited_token(10,240)

    def generate_time_limited_token(note, n_chars, hours_to_expiration) do
      token_record = Utility.generate_time_limited_token(n_chars,hours_to_expiration)
      tokens = (note.tokens || []) ++ [token_record]
      changeset = Note.changeset(note, %{tokens: tokens})
      Repo.update(changeset)
      token_record
    end

    def match_token(given_token, token_record) do
      token_record["token"] == given_token
    end

    def match_token_array(given_token, note) do
      Enum.reduce(note.tokens, false, fn(token_record, acc) -> match_token(given_token, token_record) or acc end)
    end

    def add_options(options, note) do

        options = Map.merge(options, %{note_id: note.id})

        cond do
          Enum.member?(note.tags, ":latex") -> Map.merge(options, %{process: "latex"})
          Enum.member?(note.tags, ":collate") -> Map.merge(options, %{process: "collate", user_id: note.user_id})
          Enum.member?(note.tags, ":toc") -> Map.merge(options, %{process: "toc", user_id: note.user_id})
          Enum.member?(note.tags, ":plain") -> Map.merge(options, %{process: "plain"})
          true -> Map.merge(options, %{process: "markup"})
        end

    end

    def get(id) do
      IO.puts "Note.get(#{id})"
      cond do
        is_integer(id) -> note = Repo.get!(Note, id)
        Regex.match?(~r/^[A-Za-z].*/, id) -> note = Identifier.find_note(id)
        true -> note = Repo.get!(Note, String.to_integer(id))
      end
      IO.puts "Note.get => title = #{note.title}"
      note
      # note = note || Identifier.find_note(Constant.not_found_note())
      # Repo.preload(note, :user).user
      # note
    end

    #### SEARCH AND SORT -- COMPOSABLE QUERIES ####

    # https://blog.drewolson.org/composable-queries-ecto/

    def for_user(query, user_id) do
      from n in query,
        where: n.user_id == ^user_id
    end

    def sort_by_viewed_at(query) do
        from n in query,
        order_by: [desc: n.viewed_at]
    end

    def select_by_channel(query, channel) do
       [username, tag] = String.split(channel, ".")
       user = User.find_by_username(username)
       Utility.report("Note, select_by_channel", [username, tag] )
       if user == nil do
         user_id = -1
       else
         user_id = user.id
       end
       IO.puts " ... select_by_channel, user_id = #{user_id}"
       if Enum.member?(["all", "public"], tag) do
          from n in query,
            where: n.user_id == ^user_id
        else
          from n in query,
            where: n.user_id == ^user_id and ^tag in n.tags
        end
    end

   def select_by_user_and_tag(query, user, tag) do
       Utility.report("INPUT, select_by_user_and_tag", [query, user, tag])
       if Enum.member?(["all", "public"], tag) do
         from n in query,
           where: n.user_id == ^user.id
       else
         from n in query,
           where: n.user_id == ^user.id and ^tag in n.tags
       end
    end

    def select_by_viewed_at_hours_ago(query, hours_ago) do
        then = Timex.shift(Timex.now, [hours: -hours_ago])
        from n in query,
        where: n.channel == n.viewed_at >= ^then
    end

    def select_public(query, public) do
      if public == true do
        from n in query,
           where: n.public == ^true
      else
        query
      end
    end

    def select_by_tag(query, tag_list, condition \\ true) do
      if !is_list(tag_list) do
        tag_list = [tag_list]  # THIS IS BAD CODE -- TRACK THINS DOWN AND FIX
      end
      Utility.report("select_by_tag, tag_list", tag_list)
      if condition do
        from n in query,
          where: ilike(n.tag_string, ^"%#{hd(tag_list)}%")
       else
         query
       end
    end


   def select_by_term(query, term, condition \\ true) do
      IO.puts "select_by_term, term = #{term}"
      if condition do
        from n in query,
          where: ilike(n.title, ^"%#{term}%") or ilike(n.tag_string, ^"%#{term}%")
       else
         query
       end
    end

   def full_text_search(query, term, condition \\ false) do
      IO.puts "full_text_search, term = #{term}"
      if condition do
        from n in query,
          where: ilike(n.content, ^"%#{term}%")
       else
         query
       end
    end

    def most_recent(items, n) do
      Enum.slice(items, 0..(n-1))
    end




end

