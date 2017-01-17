defmodule LookupPhoenix.Note do
  use LookupPhoenix.Web, :model

  use Ecto.Schema
  import Ecto.Query
  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo

  schema "notes" do
    field :title, :string
    field :content, :string
    field :user_id, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :content, :user_id])
    |> validate_required([:title, :content])
  end


    def search_by_title(arg) do
      Ecto.Query.from(p in Note, where: ilike(p.title, ^"%#{List.first(arg)}%"))
      |> Repo.all
    end

    def count_for_user(user_id) do
      query = Ecto.Query.from note in Note,
         select: note.id,
         where: note.user_id == ^user_id
         length Repo.all(query)
    end

    def notes_for_user(user_id) do
       query = Ecto.Query.from note in Note,
         select: note.id,
         where: note.user_id == ^user_id
         Repo.all(query)
         |> getDocumentsFromList
    end


    def search_with_non_empty_arg(arg, user_id) do
      result = Ecto.Query.from(p in Note, where: ilike(p.title, ^"%#{List.first(arg)}%") or ilike(p.content, ^"%#{List.first(arg)}%"))
      |> Repo.all
      |> Note.filter_records_for_user(user_id)
      |> Note.filter_records_with_term_list(tl(arg))
      Note.memorize_list(result, user_id)
      Enum.map(result, fn (record) -> record.id end)
      result
    end

    def search(arg, user_id) do
      arg = Enum.map(arg, fn(x) -> String.downcase(x) end)
      case arg do
        [] -> []
        _ -> search_with_non_empty_arg(arg, user_id)
      end
    end

    def filter_records_for_user(list, user_id) do
      Enum.filter(list, fn(x) -> x.user_id == user_id end)
    end

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

    def random(p, user_id) do
      {_ok, result} = Ecto.Adapters.SQL.query(Repo, "SELECT id FROM notes TABLESAMPLE BERNOULLI(#{p})")
      id_list = result.rows
      |> List.flatten
      |> Enum.filter(fn(x) -> is_integer(x) end)
      |> ListUtil.mcut
      Note.memorize_list(id_list, user_id)
      Mnemonix.put(Cache, :active_notes, id_list)
      id_list
      |> getDocumentsFromList
      |> filter_records_for_user(user_id)
    end

    def linkify(text) do
      #text = Regex.replace(~r/((http|https):\/\/\S*)\s/, " "<>text<>" ",  "<a href=\"\\1\" target=\"_blank\">LINK</a> ")
      text = Regex.replace(~r/((http|https):\/\/[a-zA-Z0-9\.\-\/&=\?#@_%]*)\s/, " "<>text<>" ",  "<a href=\"\\1\" target=\"_blank\">LINK</a> ")
      Regex.replace(~r/((http|https):\/\/[a-zA-Z0-9\.\-\/&=\?#@_%]*)\[(.*)\]\s/, " "<>text<>" ",  "<a href=\"\\1\" target=\"_blank\">\\3</a> ")
    end

    def makeLink(text) do
        Regex.replace(~r/((https|http):\/\/([a-zA-Z0-9_:\-\.]*)[a-zA-Z0-9\.\-=@#&_%!\?\/]*)\s/, " "<>text<>" ",
          "<a href=\"\\1\" target=\"_blank\">\\3</a> ")

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

end

