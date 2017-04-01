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

     def extract_id_list(list) do
       list |> Enum.map(fn(note) -> note.id end) |> Enum.join(",")
     end

     def fromPair(pair) do
          %Note{ :title => "Foo", :content => "Bar"}
     end

     def count do
       Repo.aggregate(Note, :count, :id)
     end

    def identity(text) do
      text
    end

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


end
