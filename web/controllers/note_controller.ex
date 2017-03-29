defmodule LookupPhoenix.NoteController do
  use LookupPhoenix.Web, :controller
  use Timex

  alias LookupPhoenix.Note
  alias LookupPhoenix.User
  alias LookupPhoenix.Tag
  alias LookupPhoenix.Search
  alias LookupPhoenix.Utility
  alias LookupPhoenix.Constant
  alias LookupPhoenix.Identifier

  alias LookupPhoenix.NoteIndexAction
  alias LookupPhoenix.NoteShowAction
  alias LookupPhoenix.NoteShow2Action
  alias LookupPhoenix.NoteCreateAction

  alias MU.RenderText
  alias MU.LiveNotebook
  alias MU.TOC



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
  def index(conn, params) do

     current_user = conn.assigns.current_user
     qsMap = Utility.qs2map(conn.query_string)
     mode = qsMap["mode"]

     result = NoteIndexAction.call(current_user, qsMap)
     note_record = result.note_record
     note_count_string = result.note_count_string

     id_list = Note.recall_list(current_user.id)

     options = %{mode: "index", process: "none"}

     notes = Utility.add_index_to_maplist(note_record.notes)
     id_string = Note.extract_id_list(notes)
     params2 = %{current_user: current_user, notes: notes, id_string: id_string,
         noteCountString: note_count_string, options: options}

     if qsMap["set_channel"] == nil do
       conn
       |> put_resp_cookie("site", current_user.username)
       |> render("index.html", params2)
     else
       conn
       |> put_resp_cookie("site", current_user.username)
       |> redirect(to: "/notes?mode=all")
     end

  end

  defp read_only_message(conn) do
      conn
      |> put_flash(:info, "Sorry, these notes are read-only.")
      |> redirect(to: note_path(conn, :index))
  end

  ########## NEW ########

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
        {:ok, _note} ->
          [_note.id] ++ Note.recall_list(conn.assigns.current_user.id)
          |> Note.memorize_list(conn.assigns.current_user.id)
          conn
          |> put_flash(:info, "Note created successfully: #{_note.id}")
          |> redirect(to: note_path(conn, :index, active_notes: [_note.id], random: "no"))
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
  end # SHOW





  ###############

  def mailto(conn, %{"id" => id}) do

   params2 = Note.decode_query_string(conn.query_string)

    Utility.report("params2", params2)


    note = Repo.get!(Note, id)
    message_part_1 = "This note is courtesy of http://www.lookupnote.io\n\n"
    message_part_2= "It is available at http://www.lookupnote.io/share/"
    message_part_4 = "\n\n\n------\nIf you wish to sign up for an account on lookupnote.io,\n please use this registation code: student "

    if note.identifier == nil do
      note_id = note.id
    else
      note_id = note.identifier
    end

    if note.public == false do
      token_record = Note.generate_time_limited_token(note, 10, 240)
      message_part_3= "#{note_id}?#{token_record.token}"
    else
      message_part_3= "#{note_id}"
    end

    email_body = message_part_1 <> message_part_2 <> message_part_3 <> message_part_4
          |> String.replace("\n", "%0D%0A")

    # @current_id, index: @index, id_string: @id_string, note: @note

    params1 = %{note: note, email_body: email_body}

    params = Map.merge(params1, params2)

    render(conn, "mailto.html", params)
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

  defp params_for_save(conn, note, params, changeset, rendered_text) do
    locked = conn.assigns.current_user.read_only
    word_count = RenderText.word_count(note.content)

    params1 = %{note: note, changeset: changeset,
                            word_count: word_count, locked: locked,
                            conn: conn, rendered_text: rendered_text}

     params = Map.merge(params, params1)
  end

  defp doUpdate(note, note_params, save_option, conn) do

    new_content = Regex.replace(~r/ß/, note_params["content"], "")
    new_title = Regex.replace(~r/ß/, note_params["title"], "")

    tags = Tag.str2tags(note_params["tag_string"])

    new_params = Map.merge(note_params, %{"content" => new_content, "title" => new_title,
        "tags" => tags, "edited_at" => Timex.now})

    changeset = Note.changeset(note, new_params)
    current_user = conn.assigns.current_user
    changeset = Ecto.Changeset.update_change(changeset, :identifier, fn(ident) -> Identifier.normalize(current_user, ident) end)

    index = conn.params["index"]
    id_string = conn.params["id_string"]
    params = Note.decode_query_string("index=#{index}&id_string=#{id_string}")
    params = Map.merge(params, %{random: "no"})
    rendered_text = RenderText.transform(new_content, Note.add_options(%{mode: "show", public: note.public, toc_history: ""}, note))

    if save_option != "exit"  do
      params = params_for_save(conn, note, params, changeset, rendered_text)
    end

    live_tags = note.tags |> Enum.filter(fn(tag) -> Regex.match?(~r/live/, tag) end)
    if live_tags != [] do LiveNotebook.update(note) end

    case Repo.update(changeset) do
      {:ok, note} ->
        if save_option == "exit" do
          conn
          |> redirect(to: note_path(conn, :show, note, params))
        else
          conn
          |> render "edit.html", params
        end
      {:error, _changeset} ->
          conn
          |> put_flash(:info, "ERROR - is the identifier you proposed unique?")
          |> render "edit.html", params

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
