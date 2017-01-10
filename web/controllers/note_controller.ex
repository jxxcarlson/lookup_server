defmodule LookupPhoenix.NoteController do
  use LookupPhoenix.Web, :controller

  alias LookupPhoenix.Note



  def index(conn, _params) do
    IO.puts "---------"
    IO.puts "active_notes"
    IO.inspect _params["active_notes"]
    IO.puts "---------"
    # notes = Repo.all(Note)
    id_list = Mnemonix.get(Cache, :active_notes)
    notes = Note.getDocumentsFromList(id_list)
    render(conn, "index.html", notes: notes, noteCountString: "")
  end

  def new(conn, _params) do
    changeset = Note.changeset(%Note{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"note" => note_params}) do
    new_content = Note.makeLink(note_params["content"])
    new_params = %{"content" => new_content, "title" => note_params["title"]}
    changeset = Note.changeset(%Note{}, new_params)

    case Repo.insert(changeset) do
      {:ok, _note} ->
        Mnemonix.put(Cache, :active_notes, [_note.id])
        conn
        |> put_flash(:info, "Note created successfully: #{_note.id}")
        |> redirect(to: note_path(conn, :index, active_notes: [_note.id]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    note = Repo.get!(Note, id)
    render(conn, "show.html", note: note)
  end

  def edit(conn, %{"id" => id}) do
    note = Repo.get!(Note, id)
    changeset = Note.changeset(note)
    render(conn, "edit.html", note: note, changeset: changeset)
  end

  def update(conn, %{"id" => id, "note" => note_params}) do
    note = Repo.get!(Note, id)
    changeset = Note.changeset(note, note_params)

    case Repo.update(changeset) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note updated successfully.")
        |> redirect(to: note_path(conn, :show, note))
      {:error, changeset} ->
        render(conn, "edit.html", note: note, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    note = Repo.get!(Note, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(note)

    conn
    |> put_flash(:info, "Note deleted successfully.")
    |> redirect(to: note_path(conn, :index))
  end
end
