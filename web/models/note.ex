defmodule LookupPhoenix.Note do
  use LookupPhoenix.Web, :model

  use Ecto.Schema
  import Ecto.Query
  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo

  schema "notes" do
    use Timex.Ecto.Timestamps

    field :title, :string
    field :content, :string
    field :user_id, :integer
    field :viewed_at, :utc_datetime

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :content, :user_id, :viewed_at])
    |> validate_required([:title, :content])
  end


    def search_by_title(arg) do
      Ecto.Query.from(p in Note, where: ilike(p.title, ^"%#{List.first(arg)}%"))
      |> Repo.all
    end

    def udpated_before_date(hours, date_time, user_id) do
       then = Timex.shift(date_time, [hours: -hours])
       query = Ecto.Query.from note in Note,
          select: note.id,
          where: note.user_id == ^user_id and note.updated_at >= ^then,
          order_by: [desc: note.updated_at]
        Repo.all(query)
        |> getDocumentsFromList
    end

    def viewed_before_date(hours, date_time, user_id) do
       then = Timex.shift(date_time, [hours: -hours])
       query = Ecto.Query.from note in Note,
          select: note.id,
          where: note.user_id == ^user_id and note.viewed_at >= ^then,
          order_by: [desc: note.viewed_at]
        Repo.all(query)
        |> getDocumentsFromList
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
         where: note.user_id == ^user_id,
         order_by: [desc: note.updated_at]
       Repo.all(query)
       |> getDocumentsFromList
    end


    def search_with_non_empty_arg(arg, user_id) do
      query = Ecto.Query.from note in Note,
         where: (ilike(note.title, ^"%#{List.first(arg)}%") or ilike(note.content, ^"%#{List.first(arg)}%")),
         order_by: [desc: note.updated_at]
      result = Repo.all(query)
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

    # Get list of random note ids
    def random_ids(p) do
      {_ok, result} = Ecto.Adapters.SQL.query(Repo, "SELECT id FROM notes TABLESAMPLE BERNOULLI(#{p})")
      id_list = result.rows
      |> List.flatten
      |> Enum.filter(fn(x) -> is_integer(x) end)
      |> ListUtil.mcut
    end

    # Get list of random note ids for given user
    def random_notes_for_user(p, user_id, truncate_at \\ 7) do
      random_ids(p)
      |> getDocumentsFromList
      |> filter_records_for_user(user_id)
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


    #######

    def transform_text(text, height \\ 200) do
      linkify(text, height)
      |> apply_markdown
    end


    def linkify(text, height \\ 200) do
      text
      |> simplifyURLs
      |> makeUserLinks
      |> makeSmartLinks
      |> makeImageLinks(height)
      |> String.trim
    end

    def apply_markdown(text) do
      text
      |> formatCode
      |> formatInlineCode
      |> formatMDash
      |> formatNDash
      |> formatStrike
      |> formatBold
      |> formatItalic
      |> formatRed
    end

    def getURLs(text) do
      Regex.scan(~r/((http|https):\/\/\S*)\s/, " " <> text <> " ", [:all])
      |> Enum.map(fn(x) -> hd(tl(x)) end)
    end

    def prepURLs(url_list) do
       Enum.map(url_list, fn(x) -> [x, hd(String.split(x, "?"))] end)
    end

    def simplify_one_URL(substitution_item, text) do
      target = hd(substitution_item)
      replacement = hd(tl(substitution_item))
      String.replace(text, target, replacement)
    end

    def simplifyURLs(text) do
      url_substitution_list = text |> getURLs |> prepURLs
      Enum.reduce(url_substitution_list, text, fn(substitution_item, text) -> simplify_one_URL(substitution_item, text) end)
    end

    def preprocessImageURLs(text) do
      # Regex.replace(~r/\s((http|https):\/\/\S*\.(jpg|jpeg|png))\s/i, text, "image::\\1 ")
      Regex.replace(~r/[^:]((http|https):\/\/\S*\.(jpg|jpeg|png))\s/i, text, " image::\\1 ")
    end

    def preprocessURLs(text) do
      text
      |> simplifyURLs
      |> preprocessImageURLs
    end

    def makeDumbLinks(text) do
      Regex.replace(~r/\s((http|https):\/\/[a-zA-Z0-9\.\-\/&=\?#!@_%]*)\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">LINK</a> ")
    end

    # ha ha http://foo.bar.io/a/b/c blah blah => 1: http://foo.bar.io/a/b/c, 3: foo.bar.io
    def makeSmartLinks(text) do
       Regex.replace(~r/\s((http|https):\/\/([a-zA-Z0-9\.\-_%]*)([\/?=#]\S*|))\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
    end

    # http://foo.io/ladidah/mo/stuff => <a href="http://foo.io/ladida/foo.io"" target=\"_blank\">foo.io/ladidah</a>
    def makeUserLinks(text) do
      Regex.replace(~r/\s((http|https):\/\/[a-zA-Z0-9\.\-\/&=\?#!@_%]*)\[(.*)\]\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
    end

    def makeImageLinks(text, height \\ 200) do
       Regex.replace(~r/\simage::(.*(png|jpg|jpeg|JPG|JPEG|PNG))\s/, " "<>text<>" ", " <img src=\"\\1\" height=#{height}> ")
    end

    def formatNDash(text) do
      # \s(--)\s
      Regex.replace(~r/\s(--)\s/, text, " &ndash; ")
    end

    def formatMDash(text) do
       Regex.replace(~r/\s(---)\s/, text, " &mdash; ")
    end

    def formatStrike(text) do
       Regex.replace(~r/\s-(.*)-\s/r, text, " <span style='text-decoration: line-through'>\\1</span> ")
    end

    def formatInlineCode(text) do
      Regex.replace(~r/\`(.*)\`/r, text, "<tt style='color:darkred; font-weight:400'>\\1</tt>")
    end

    def formatCode(text) do
      Regex.replace(~r/----(?:\r\n|[\r\n])(.*)(?:\r\n|[\r\n])----/msr, text, "<pre>\\1</pre>")
    end

    # ``\n(.*)\n```

    def formatBold(text) do
       Regex.replace(~r/(\*(.*)\*)/r, text, "<strong>\\2</strong>")
    end

    def formatItalic(text) do
       Regex.replace(~r/ _(.*)_ /r, text, "<i>\\1</i>")
    end

    def formatRed(text) do
       Regex.replace(~r/red:\[(.*)\]/r, text, "<span style='color:darkred'>\\1</span>")
    end

    def scrubTags(text) do
      Regex.replace(~r/\s:.*\s/, " " <> text <> " ",    " ")
    end

    def firstParagraph(text) do
      short_text = Regex.run(~r/.*\s\s/, text)
      case short_text do
        nil -> text
        [] -> text
        _ -> (List.first short_text) <> " •••"
      end
    end

    def format_for_index(text) do
      text
      |> firstParagraph
      |> linkify
    end

    ########



    ##########

    def memorize_notes(note_list, user_id) do
      note_list
      |> Enum.map(fn(note) -> note.id end)
      |> memorize_list(user_id)
    end

    def memorize_list(id_list, user_id) do
      new_id_list = Enum.filter(id_list, fn x -> is_integer(x) end)
      IO.puts "=========================="
      IO.puts "Memorizing #{length(id_list)} notes for #{user_id}"
      IO.puts "=========================="
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

  def init_viewed_at(note) do
      then = Timex.shift(Timex.now, [hours: -30])
      params = %{"viewed_at" => then}
      changeset = Note.changeset(note, params)
      Repo.update(changeset)
  end

  def init_notes_viewed_at do
    Note |> Repo.all |> Enum.map(fn(note) -> Note.init_viewed_at(note) end)
  end

end

