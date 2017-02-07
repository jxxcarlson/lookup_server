defmodule LookupPhoenix.NoteController do
  use LookupPhoenix.Web, :controller
  use Timex

  alias LookupPhoenix.Note


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
  end

  def index(conn, _params) do
     user_id = conn.assigns.current_user.id
     id_list = Note.recall_list(user_id)
     if length(id_list) == 0 do
       notes = getRandomNotes(user_id)
     else
       notes = Note.getDocumentsFromList(id_list)
     end
     noteCountString = "#{length(notes)} Notes"
     render(conn, "index.html", notes: notes, noteCountString: noteCountString)
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
        render(conn, "new.html", changeset: changeset, locked: locked)
    end
  end

  def create(conn, %{"note" => note_params}) do
    if (conn.assigns.current_user.read_only == true) do
         read_only_message(conn)
    else
      new_content = Regex.replace(~r/ß/, note_params["content"], "") |> RenderText.preprocessURLs
      new_title = Regex.replace(~r/ß/, note_params["title"], "")
      new_params = %{"content" => new_content, "title" => new_title,
         "user_id" => conn.assigns.current_user.id, "viewed_at" => Timex.now, "edited_at" => Timex.now}
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
    note = Repo.get!(Note, id)
    Note.update_viewed_at(note)
    inserted_at= Note.inserted_at(note)
    {:ok, updated_at }= note.updated_at |> Timex.local |> Timex.format("{Mfull} {D}, {YYYY}")
    render(conn, "show.html", note: note, inserted_at: inserted_at, updated_at: updated_at)
  end


  def edit(conn, %{"id" => id}) do
        note = Repo.get!(Note, id)
        changeset = Note.changeset(note)
        locked = conn.assigns.current_user.read_only
        render(conn, "edit.html", note: note, changeset: changeset, locked: locked, conn: conn)
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
    new_params = %{"content" => new_content, "title" => new_title, "edited_at" => Timex.now}
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
