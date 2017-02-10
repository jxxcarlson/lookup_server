defmodule LookupPhoenix.NoteController do
  use LookupPhoenix.Web, :controller
  use Timex

  alias LookupPhoenix.Note
  alias LookupPhoenix.Tag
  alias LookupPhoenix.Utility


  def report(message, object) do
    IO.puts "========================"
        IO.puts message
        IO.inspect object
        IO.puts "========================"
  end

  def getRandomNotes(user_id) do
     note_count = Note.count_for_user(user_id)
     expected_number_of_entries = 7
     cond do
       note_count > 14 ->
          p = (100*expected_number_of_entries) / note_count
          notes = LookupPhoenix.Note.random_notes_for_user(p, user_id)
       note_count <= 14 ->
          notes = Note.notes_for_user(user_id)
     end

     notes = Utility.add_index_to_maplist(notes)

  end

  def index(conn, _params) do
     user_id = conn.assigns.current_user.id
     id_list = Note.recall_list(user_id)

     if length(id_list) == 0 do
       notes = getRandomNotes(user_id)
     else
       notes = Note.getDocumentsFromList(id_list)
     end

     options = %{mode: "index", process: "none"}
     noteCountString = "#{length(notes)} Notes"

     notes = Utility.add_index_to_maplist(notes)
     id_string = Note.extract_id_list(notes)

     render(conn, "index.html", notes: notes, id_list: id_string, noteCountString: noteCountString, options: options)
  end

  def read_only_message(conn) do
      conn
      |> put_flash(:info, "Sorry, these notes are read-only.")
      |> redirect(to: note_path(conn, :index))
  end

  def new(conn, _params) do
    locked = conn.assigns.current_user.read_only
    if (locked) do
           read_only_message(conn)
    else
        changeset = Note.changeset(%Note{})
        render(conn, "new.html", changeset: changeset, locked: locked, word_count: 0, conn: conn)
    end
  end

  def create(conn, %{"note" => note_params}) do
    if (conn.assigns.current_user.read_only == true) do
         read_only_message(conn)
    else
      new_content = Regex.replace(~r/ß/, note_params["content"], "") |> RenderText.preprocessURLs
      new_title = Regex.replace(~r/ß/, note_params["title"], "")
      tags = Tag.str2tags(note_params["tag_string"])

      new_params = %{"content" => new_content, "title" => new_title,
         "user_id" => conn.assigns.current_user.id, "viewed_at" => Timex.now, "edited_at" => Timex.now,
         "tag_string" => note_params["tag_string"], "tags" => tags}
      changeset = Note.changeset(%Note{}, new_params)

      case Repo.insert(changeset) do
        {:ok, _note} ->
          [_note.id] ++ Note.recall_list(conn.assigns.current_user.id)
          |> Note.memorize_list(conn.assigns.current_user.id)
          conn
          |> put_flash(:info, "Note created successfully: #{_note.id}")
          |> redirect(to: note_path(conn, :index, active_notes: [_note.id]))
        {:error, changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    end
  end

  def show(conn, %{"id" => id}) do

    query_data = conn.query_string |> Utility.parse_query_string
    index = query_data["index"]
    {index, _} = Integer.parse index
    id_string = query_data["id_list"]
    IO.puts "=========== show, id_string: ======="
    IO.inspect id_string
    IO.puts "===================================="
    id_list = String.split(id_string, "%2C")

    current_id = Enum.at(id_list, index)
    last_index = length(id_list) - 1
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
    next_id = Enum.at(id_list, next_index)
    previous_id = Enum.at(id_list, previous_index)


    IO.puts "====== Query Data ======="
    IO.inspect index
    IO.inspect previous_id
    IO.inspect current_id
    IO.inspect next_id
    IO.inspect id_list
    IO.inspect id_string
    IO.puts "=========================="

    note = Repo.get!(Note, id)
    Note.update_viewed_at(note)
    if Enum.member?(note.tags, "latex") do
      options = %{mode: "show", process: "latex"}
    else
      options = %{mode: "show", process: "none"}
    end
    inserted_at= Note.inserted_at(note)
    word_count = RenderText.word_count(note.content)
    {:ok, updated_at }= note.updated_at |> Timex.local |> Timex.format("{Mfull} {D}, {YYYY}")
    render(conn, "show.html", note: note,
       inserted_at: inserted_at, updated_at: updated_at,
       word_count: word_count, options: options, index: index,
       next_index: next_index, previous_index: previous_index,
       next_id: next_id, previous_id: previous_id, id_list: id_list |> Enum.join(","))
  end


  def edit(conn, %{"id" => id}) do
        note = Repo.get!(Note, id)
        changeset = Note.changeset(note)
        locked = conn.assigns.current_user.read_only
        word_count = RenderText.word_count(note.content)
        tags = Note.tags2string(note)
        render(conn, "edit.html", note: note, changeset: changeset,
          word_count: word_count, locked: locked, conn: conn, tags: tags)
  end

  def doUpdate(note, changeset, conn) do
    case Repo.update(changeset) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note updated successfully.")
        |> redirect(to: note_path(conn, :show, note))
        # |> redirect(to: note_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", note: note, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "note" => note_params}) do
    note = Repo.get!(Note, id)

    new_content = Regex.replace(~r/ß/, note_params["content"], "") |> RenderText.preprocessURLs
    new_title = Regex.replace(~r/ß/, note_params["title"], "")

    tags = Tag.str2tags(note_params["tag_string"])

    new_params = %{"content" => new_content, "title" => new_title,
      "edited_at" => Timex.now, "tag_string" => note_params["tag_string"], "tags" => tags}

    changeset = Note.changeset(note, new_params)
    if (conn.assigns.current_user.read_only == false) do
        doUpdate(note, changeset, conn)
    else
       read_only_message(conn)
    end
  end

  def delete(conn, %{"id" => id}) do
    if (conn.assigns.current_user.read_only == true) do
       read_only_message(conn)
    else
       note = Repo.get!(Note, id)

       # Here we use delete! (with a bang) because we expect
       # it to always work (and if it does not, it will raise).
       Repo.delete!(note)


       n = String.to_integer(id)
       Note.recall_list(conn.assigns.current_user.id)
       |> List.delete(n)
       |> Note.memorize_list(conn.assigns.current_user.id)


       conn
       |> put_flash(:info, "Note deleted successfully.")
       |> redirect(to: note_path(conn, :index))
    end
  end

  def grab(conn, url) do

  end



end
