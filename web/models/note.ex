defmodule LookupPhoenix.Note do
  use LookupPhoenix.Web, :model

  use Ecto.Schema
  import Ecto.Query
  alias LookupPhoenix.Note
  alias LookupPhoenix.User
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility
  alias LookupPhoenix.Constant

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

     def set_public_for_user(user_id, value) do
        options = %{}
        notes_for_user(user_id)|> Enum.map(fn(note) -> Note.set_public(note, value) end)
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

    ## test
    def erase_string_in_all_notes(str) do
         Note |> Repo.all |> Enum.map(fn(note) -> Note.erase_string(note, str) end)
     end

    def add_options(options, note) do

        if Enum.member?(note.tags, "latex") do
            options = Map.merge(options, %{process: "latex"})
        else
            options = Map.merge(options, %{process: "none"})
        end

        if Enum.member?(note.tags, "collate") do
            options = Map.merge(options, %{collate: true, user_id: note.user_id})
        else
            options = Map.merge(options, %{collate: false})
        end
    end

    # If user is "joe"
    # joe.foobar => joe.foobar
    # hoho.foobar => joe.foobar
    # foobar => joe.foobar
    def normalize_identifier(user, identifier) do
      if String.contains?(identifier, ".") do
        identifier_parts = String.split(identifier, ".")
        if hd(identifier_parts) == user.username do
        identifier = tl(identifier_parts) |> Enum.join(".")
        end
      end
      "#{user.username}.#{identifier}"
    end

    def find_by_identifier(identifier) do
      query = Ecto.Query.from note in Note,
              where: note.identifier == ^identifier
      Repo.one(query)
    end

    def get(id) do
      IO.puts "Note.get(#{id})"
      cond do
        is_integer(id) -> note = Repo.get!(Note, id)
        Regex.match?(~r/^[A-Za-z].*/, id) -> note = find_by_identifier(id)
        true -> note = Repo.get!(Note, id)
      end
      # note = note || find_by_identifier(Constant.not_found_note())
      # Repo.preload(note, :user).user
      # note
    end

    defp random_string(length) do
       :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    end

    def make_identifier(prefix, title, length) do
      title2 = Regex.replace(~r/[^a-zA-Z0-9\-\._                                                            ]/, title, "")
      part1 = prefix <> "." <> title2
      |> String.downcase
      |> String.replace(" ", "_")
      part2 = random_string(4)
      part1 <> "." <> part2
    end

     ## INIT (ONE-TIME) ##

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


    def set_tag_string(note, value) do
      params = %{"tag_string" => value}
      changeset = Note.changeset(note, params)
      Repo.update(changeset)
    end

    def set_identifier(note) do
      if note.identifier == nil do
          user = Repo.get!(User, note.user_id)
          identifier = make_identifier(user.username, note.title, 4)
          params = %{"identifier" => identifier}
          changeset = Note.changeset(note, params)
          Repo.update(changeset)
       end
     end

    def set_identifiers do
      Note
      |> Repo.all
      |> Enum.map(fn(note) -> Note.set_identifier(note) end)
    end

    def set_bad_tags do
       Note
       |> Repo.all
       |> Enum.filter(fn(note) -> note.tag_string == nil end)
       |> Enum.map(fn(note) -> Note.set_tag_string(note, "-") end)
    end

    def count_bad_tags do
       Note
       |> Repo.all
       |> Enum.filter(fn(note) -> (note.tag_string == nil) or (note.tag_string == "-") end)
       |> Enum.reduce(0,fn(note, acc) -> acc + 1 end)
    end




end

