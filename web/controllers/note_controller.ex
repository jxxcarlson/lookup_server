defmodule LookupPhoenix.NoteController do
  use LookupPhoenix.Web, :controller
  use Timex

  alias LookupPhoenix.Note
  alias LookupPhoenix.Tag
  alias LookupPhoenix.Utility

  def getRandomNotes(current_user, tag \\ "none") do
      [_access, channel_name, user_id] = Note.decode_channel(current_user)

     Utility.report("channel_name in getRandomNotes", channel_name)

     note_count = Note.count_for_user(user_id, tag)
     expected_number_of_entries = 7
     cond do
       note_count > 14 ->
          p = (100*expected_number_of_entries) / note_count
          notes = Note.random_notes_for_user(p, current_user, 7, tag)
       note_count <= 14 ->
          notes = Note.notes_for_user(user_id, %{"tag" => tag, "sort_by" => "created_at", "direction" => "desc"})
     end

     notes = Utility.add_index_to_maplist(notes)

  end

  def index(conn, _params) do

     user = conn.assigns.current_user
     [channel_user_name, channel_name] = user.channel |> String.split(".")

     id_list = Note.recall_list(user.id)
     qsMap = Utility.qs2map(conn.query_string)
     mode = qsMap["mode"]
     channel =
     length_of_id_list = length(id_list)

     case [mode, length_of_id_list] do
       ["all", _] -> notes = Note.notes_for_user(user.id, %{"tag" => channel_name, "sort_by" => "created_at", "direction" => "desc"})
       [ _, 0 ]   -> notes = getRandomNotes(conn.assigns.current_user)
       _ -> notes = Note.getDocumentsFromList(id_list)

     end

     options = %{mode: "index", process: "none"}
     noteCountString = "#{length(notes)} Notes"

     notes = Utility.add_index_to_maplist(notes)
     id_string = Note.extract_id_list(notes)
     params = %{notes: notes, id_string: id_string, noteCountString: noteCountString, options: options}

     render(conn, "index.html", params)
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
        render(conn, "new.html", changeset: changeset, locked: locked, word_count: 0, conn: conn, index: 0, id_string: "[0,1]" )
    end
  end

  def create(conn, %{"note" => note_params}) do
    if (conn.assigns.current_user.read_only == true) do
         read_only_message(conn)
    else
      [access, channel_name, user_id] = Note.decode_channel(conn.assigns.current_user)
      new_content = Regex.replace(~r/ß/, note_params["content"], "") |> RenderText.preprocessURLs
      new_title = Regex.replace(~r/ß/, note_params["title"], "")

      if !Enum.member?(["all", "public"], channel_name) do
        tagstring = [note_params["tag_string"], channel_name] |> Enum.join(", ")
      else
        tagstring = note_params["tag_string"]
      end

      tags = Tag.str2tags(tagstring)

      new_params = %{"content" => new_content, "title" => new_title,
         "user_id" => conn.assigns.current_user.id, "viewed_at" => Timex.now, "edited_at" => Timex.now,
         "tag_string" => tagstring, "tags" => tags, "public" => false}
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
    if Enum.member?(note.tags, "latex") do
      options = %{mode: "show", process: "latex"}
    else
      options = %{mode: "show", process: "none"}
    end

    inserted_at= Note.inserted_at(note)
    word_count = RenderText.word_count(note.content)

    params1 = %{note: note, inserted_at: inserted_at, updated_at: note.updated_at,
                  options: options, word_count: word_count}
    params2 = Note.decode_query_string(conn.query_string)
    params = Map.merge(params1, params2)

    {:ok, updated_at } = note.updated_at |> Timex.local |> Timex.format("{Mfull} {D}, {YYYY}")
    IO.puts "UPDATED AT: #{updated_at}"
    render(conn, "show.html", params)
  end




  def edit(conn, %{"id" => id}) do

        note = Repo.get!(Note, id)
        changeset = Note.changeset(note)
        locked = conn.assigns.current_user.read_only
        word_count = RenderText.word_count(note.content)
        tags = Note.tags2string(note)

        params1 = %{note: note, changeset: changeset,
                    word_count: word_count, locked: locked,
                    conn: conn, tags: tags}
        params2 = Note.decode_query_string(conn.query_string)
        params = Map.merge(params1, params2)

        render(conn, "edit.html", params)

  end

  def doUpdate(note, changeset, conn) do

    index = conn.params["index"]
    id_string = conn.params["id_string"]
    params = Note.decode_query_string("index=#{index}&id_string=#{id_string}")

    case Repo.update(changeset) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note updated successfully.")
        |> redirect(to: note_path(conn, :show, note, params))
        # |> redirect(to: note_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", note: note, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "note" => note_params}) do

    note = Repo.get!(Note, id)
    user = conn.assigns.current_user

    new_content = Regex.replace(~r/ß/, note_params["content"], "") |> RenderText.preprocessURLs
    new_title = Regex.replace(~r/ß/, note_params["title"], "")

    tags = Tag.str2tags(note_params["tag_string"])

    new_params = %{"content" => new_content, "title" => new_title,
      "edited_at" => Timex.now, "tag_string" => note_params["tag_string"],
      "tags" => tags, "public" => note_params["public"]}

    changeset = Note.changeset(note, new_params)


    if ((user.read_only == false) and (note.user_id ==  user.id)) do
      doUpdate(note, changeset, conn)
    else
      read_only_message(conn)
    end
  end

  def delete(conn, %{"id" => id}) do

    user = conn.assigns.current_user

    note = Repo.get!(Note, id)
    if (user.read_only == true) or (user.id != note.user_id) do
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
