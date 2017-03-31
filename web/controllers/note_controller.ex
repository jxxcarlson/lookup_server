defmodule LookupPhoenix.NoteController do
  use LookupPhoenix.Web, :controller
  use Timex

  alias LookupPhoenix.Note
  alias LookupPhoenix.User
  alias LookupPhoenix.Utility

  alias LookupPhoenix.NoteIndexAction
  alias LookupPhoenix.NoteShowAction
  alias LookupPhoenix.NoteShow2Action
  alias LookupPhoenix.NoteCreateAction
  alias LookupPhoenix.NoteUpdateAction
  alias LookupPhoenix.NoteMailtoAction

  alias MU.RenderText
  alias MU.LiveNotebook



   def cookies(conn, cookie_name) do
     conn.cookies[cookie_name]
   end

  # Params: random = yes|no
  # /notes?channel=demo.art - perform search and set channel
  # /notes?random=one|many
  # /notes
  # Searches for notes are always conducted in a channel
  # To implement
  #
  # notes?recent=25
  # notes?tag=science
  # notes?search=foo%20bar%20baz
  # notes?search=
  # MORE?
  def index(conn, _params) do

     result = NoteIndexAction.call(conn)

   if result.branch == "site"  do
       conn
       |> put_resp_cookie("site", conn.assigns.current_user.username)
       |> render("index.html", result)
   else
       conn
       |> put_resp_cookie("site", conn.assigns.current_user.username)
       |> redirect(to: "/notes?mode=all")
   end

  end

  defp read_only_message(conn) do
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
      result = NoteCreateAction.call(conn, note_params)
      case Repo.insert(result.changeset) do
        {:ok, note} ->
          [note.id] ++ Note.recall_list(conn.assigns.current_user.id)
          |> Note.memorize_list(conn.assigns.current_user.id)
          conn
          |> put_flash(:info, "Note created successfully: #{note.id}")
          |> redirect(to: note_path(conn, :index, active_notes: [note.id], random: "no"))
        {:error, changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    end
  end


  def set_channel(conn, params) do
    current_user = conn.assigns.current_user
    Utility.report("PARAMS[SET]", params["set"])
    channel = params["set"]["channel"]
    IO.puts "THIS IS: Note controller, set_channel, channel = #{channel}"
    if channel == nil or channel == "" do
      channel = "#{conn.assigns.current_user.username}.all"
    end
    if current_user != nil do
      IO.puts "USER . SET CHANNEL TO #{channel} for user #{current_user.username}"
      User.update_channel(current_user, channel)
    end
    redirect(conn, to: "/notes?channel=#{channel}")
  end


  defp do_show2(conn, note) do
      text = note.content
      lines =  String.split(String.trim(text), ["\n", "\r", "\r\n"])
      |> Enum.filter(fn(line) -> !Regex.match?(~r/^title/, line) end)
      first_line  = hd(lines)
      [id2, _] = String.split(first_line, ",")
      redirect(conn, to: "/show2/#{note.id}/#{id2}/#{note.id}>#{id2}")
  end

  def show(conn, %{"id" => id}) do

    note = Note.get(id)
    LiveNotebook.auto_update(note)

    if Enum.member?(note.tags, ":toc") do
      do_show2(conn, note)
    else
      result = NoteShowAction.call(conn, note)
      render(conn, "show.html", result.params)
    end

  end


  def show2(conn, %{"id" => id, "id2" => id2, "toc_history" => toc_history}) do
    params = NoteShow2Action.call(conn, %{"id" => id, "id2" => id2, "toc_history" => toc_history})
    render(conn, "show2.html", params)
  end


  def mailto(conn, %{"id" => id}) do
    result = NoteMailtoAction.call(conn, %{"id" => id})
    render(conn, "mailto.html", result.params)
  end


  def edit(conn, %{"id" => id}) do

        note = Repo.get!(Note, id)
        changeset = Note.changeset(note)
        locked = conn.assigns.current_user.read_only
        word_count = RenderText.word_count(note.content)
        tags = Note.tags2string(note)

        rendered_text = RenderText.transform(note.content, %{mode: "latex", toc: false, mode: "show", process: "latex"})

        params1 = %{note: note, changeset: changeset,
                    word_count: word_count, locked: locked,
                    conn: conn, tags: tags, note: note, rendered_text: rendered_text}
        params2 = Note.decode_query_string(conn.query_string)
        params = Map.merge(params1, params2)

        render(conn, "edit.html", params)

  end

  defp doUpdate(note, note_params, save_option, conn) do

    result = NoteUpdateAction.call(note, note_params, save_option, conn)

    case Repo.update(result.changeset) do
      {:ok, note} ->
        if save_option == "exit" do
          conn
          |> redirect(to: note_path(conn, :show, note, result.params))
        else
          conn
          |> render "edit.html", result.params
        end
      {:error, _changeset} ->
          conn
          |> put_flash(:info, "ERROR - is the identifier you proposed unique?")
          |> render "edit.html", result.params

    end
  end

  def update(conn, %{"id" => id, "note" => note_params, "save_option" => save_option}) do

    note = Repo.get!(Note, id)
    user = conn.assigns.current_user

    cond do
      (note.user_id ==  user.id)  -> doUpdate(note, note_params, save_option, conn)
      ((user.read_only == true) and (note.user_id !=  user.id)) -> read_only_message(conn)
      true -> read_only_message(conn)
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
       |> redirect(to: note_path(conn, :index, random: "no"))
    end
  end


end
