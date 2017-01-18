defmodule LookupPhoenix.NoteController do
  use LookupPhoenix.Web, :controller

  alias LookupPhoenix.Note


  def report(message, object) do
    IO.puts "========================"
        IO.puts message
        IO.inspect object
        IO.puts "========================"
  end

  def index(conn, _params) do
    id_list = Note.recall_list(conn.assigns.current_user.id)
    report("Note controller - index", id_list)
    noteCountString = "#{length(id_list)} Notes"
    notes = Note.getDocumentsFromList(id_list)
    render(conn, "index.html", notes: notes, noteCountString: noteCountString)
  end

  def new(conn, _params) do
    changeset = Note.changeset(%Note{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"note" => note_params}) do
    new_content = note_params["content"]
    |> Note.identity
    new_params = %{"content" => new_content, "title" => note_params["title"], "user_id" => conn.assigns.current_user.id}
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

  def show(conn, %{"id" => id}) do
    report("Note controller - show", Note.recall_list(conn.assigns.current_user.id))
    note = Repo.get!(Note, id)
    render(conn, "show.html", note: note)
  end

  def edit(conn, %{"id" => id}) do
    note = Repo.get!(Note, id)
    # Mnemonix.put(Cache, :active_notes, [note.id])
    changeset = Note.changeset(note)
    render(conn, "edit.html", note: note, changeset: changeset)
  end

  def doUpdate(note, changeset, conn) do
    case Repo.update(changeset) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note updated successfully.")
        |> redirect(to: note_path(conn, :show, note))
      {:error, changeset} ->
        render(conn, "edit.html", note: note, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "note" => note_params}) do
    note = Repo.get!(Note, id)
    changeset = Note.changeset(note, note_params)
    if note.user_id != 0 do
      doUpdate(note, changeset, conn)
    end
  end

  def delete(conn, %{"id" => id}) do
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
