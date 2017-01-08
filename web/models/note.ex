defmodule LookupPhoenix.Note do
  use LookupPhoenix.Web, :model

  use Ecto.Schema
  import Ecto.Query
  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo

  schema "notes" do
    field :title, :string
    field :content, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :content])
    |> validate_required([:title, :content])
  end

  def search_by_title(arg) do
      Ecto.Query.from(p in Note, where: ilike(p.title, ^"%#{List.first(arg)}%"))
      |> Repo.all
    end

    def search_with_non_empty_arg(arg) do
      Ecto.Query.from(p in Note, where: ilike(p.title, ^"%#{List.first(arg)}%") or ilike(p.content, ^"%#{List.first(arg)}%"))
      |> Repo.all
      |> Note.filter_records_with_term_list(tl(arg))
    end

    def search(arg) do
      arg = Enum.map(arg, fn(x) -> String.downcase(x) end)
      case arg do
        [] -> []
        _ -> search_with_non_empty_arg(arg)
      end
    end

    def filter_records_with_term(list, term) do

      Enum.filter(list, fn(x) -> String.contains?(x.title, term) or String.contains?(x.content, term) end)

    end

    def filter_records_with_term_list(list, term_list) do

      case {list, term_list} do
        {list,[]} -> list
        {list, term_list} -> filter_records_with_term_list(
              filter_records_with_term(list, hd(term_list)), tl(term_list)
            )
      end

    end



    def random(p \\ 10) do
      {_ok, result} = Ecto.Adapters.SQL.query(Repo, "SELECT title, content FROM notes TABLESAMPLE BERNOULLI(#{p})")
      result.rows
    end

end
