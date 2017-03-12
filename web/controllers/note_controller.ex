defmodule LookupPhoenix.NoteController do
  use LookupPhoenix.Web, :controller
  use Timex

  alias LookupPhoenix.Note
  alias LookupPhoenix.User
  alias LookupPhoenix.Tag
  alias LookupPhoenix.Search
  alias LookupPhoenix.Utility

  def getRandomNotes(current_user, tag \\ "none") do
      [_access, channel_name, user_id] = User.decode_channel(current_user)

     Utility.report("channel_name in getRandomNotes", channel_name)

     note_count = Search.count_for_user(user_id, tag)
     expected_number_of_entries = 7
     cond do
       note_count > 14 ->
          p = (100*expected_number_of_entries) / note_count
          notes = Search.random_notes_for_user(p, current_user, 7, tag)
       note_count <= 14 ->
          notes = Search.notes_for_user(current_user, %{"tag" => tag, "sort_by" => "created_at", "direction" => "desc"}).notes
     end

     notes = Utility.add_index_to_maplist(notes)

  end

  def setup_index(conn, params) do

      user = conn.assigns.current_user
      qsMap = Utility.qs2map(conn.query_string)

       Utility.report("1. INDEX: qsMap", qsMap)

      cond do
        params["random"] == nil -> random_display = true
        params["random"] == "no" -> random_display = false
        params["random"] == "yes" -> random_display = true
        true -> random_display = true
      end

      Utility.report("1. options, random_display", random_display)

      channel = Utility.qs2map(conn.query_string)["set_channel"]
      if channel != nil and channel != user.channel do
        User.set_channel(user, channel)
      end

      [access, channel_name, user_id] = User.decode_channel(user)

      id_list = Note.recall_list(user.id)
      mode = qsMap["mode"]
      # channel =

      [mode, id_list, qsMap, random_display, user]
  end

  def get_note_record(mode, id_list, user, options) do
    IO.puts "GET NOTE FOR RECORD"
    case [mode, length(id_list)] do
       ["all", _] -> IO.puts "BRANCH 1"; note_record = Search.notes_for_user(user, %{"mode" => "all",
          "sort_by" => "inserted_at", "direction" => "desc"});
       ["public", _] ->  IO.puts "BRANCH 2"; note_record = Search.notes_for_user(user, %{"mode" => "public",
          "sort_by" => "inserted_at", "direction" => "desc"});
       [_, number_of_notes_remembered] ->
          if number_of_notes_remembered > 0 do
            IO.puts "BRANCH 3"; note_record = Search.getDocumentsFromList(id_list, options);
          else
            IO.puts "SEARCH NOTE FOR USER with options, random_display = "#  <> options["random_display"] <> " -- BRANCH 4"
            note_record = Search.notes_for_user(user, %{"mode" => "all",
                      "sort_by" => "inserted_at", "direction" => "desc",
                      random: options["random_display"]});
          end
       _ ->  IO.puts "BRANCH 5"; note_record = Search.getDocumentsFromList(id_list, options);

     end
  end

   def cookies(conn, cookie_name) do
     conn.cookies[cookie_name]
   end

  def index(conn, params) do

     current_user = conn.assigns.current_user
  
     [mode, id_list, qsMap, random_display, user]  = setup_index(conn, params)

     note_record = get_note_record(mode, id_list, user, %{random_display: random_display})

     options = %{mode: "index", process: "none"}

     Utility.report("2. INDEX: qsMap", qsMap)
     Utility.report("2. options, random_display", random_display )

     if note_record.original_note_count > note_record.note_count do
       noteCountString = "#{note_record.note_count} Random notes from #{note_record.original_note_count}"
     else
       noteCountString = "#{note_record.note_count} Notes"
     end

     notes = Utility.add_index_to_maplist(note_record.notes)
     id_string = Note.extract_id_list(notes)
     params2 = %{current_user: current_user, notes: notes, id_string: id_string, noteCountString: noteCountString, options: options}


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


  #### Code for create note ####

  def get_tags(note_params, channel_name) do

      # Normalize tag_string name and ensure that is non-nil and non-empty
      tag_string = note_params["tag_string"] || ""
      if is_nil(channel_name) do channel_name = "all" end
      IO.puts "tag_string: [#{tag_string}]"
      IO.puts "tag_string - nil?: #{is_nil(tag_string)}"
      IO.puts "channel_name: #{channel_name}"

      cond  do
        !Enum.member?(["all", "public"], channel_name) and tag_string != "" ->
          tag_string = [tag_string, channel_name] |> Enum.join(", ")
        !Enum.member?(["all", "public"], channel_name) and tag_string == ""  ->
          tag_string = channel_name
        tag_string == "" -> tag_string = "-"
        tag_string != "" -> tag_string
      end

      tags = Tag.str2tags(tag_string)

      Utility.report("XXX: tag info", [tag_string, tags])
      [tag_string, tags]
  end

  def setup(conn, note_params) do
      [access, channel_name, user_id] = User.decode_channel(conn.assigns.current_user)
      [tag_string, tags] = get_tags(note_params, channel_name)
      new_content = Regex.replace(~r/ß/, note_params["content"], "") |> RenderText.preprocessURLs
      new_title = Regex.replace(~r/ß/, note_params["title"], "")
      identifier = Note.make_identifier(conn.assigns.current_user.username, new_title, 4)
      new_params = %{"content" => new_content, "title" => new_title,
         "user_id" => conn.assigns.current_user.id, "viewed_at" => Timex.now, "edited_at" => Timex.now,
         "tag_string" => tag_string, "tags" => tags, "public" => false, "identifier" => identifier}
      changeset = Note.changeset(%Note{}, new_params)
  end

  def create(conn, %{"note" => note_params}) do
    if (conn.assigns.current_user.read_only == true) do
         read_only_message(conn)
    else
      changeset = setup(conn, note_params)
      case Repo.insert(changeset) do
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
    channel = params["set"]["channel"]
    IO.puts "I WILL SET THE CHANNEL TO: #{channel}"
    Utility.report("SET CHANNEL PARAMS:", params)
    User.update_channel(conn.assigns.current_user, channel)
   # render(conn, "index.html")
   ##redirect(conn, to: note_path(conn, :index))
   redirect(conn, to: "/notes?random=no")
  end

  ##########################################################


  def do_show(conn, note) do

   IO.puts("DO SHOW")

    user = Repo.get!(User, note.user_id)

    Note.update_viewed_at(note)

    # Note.add_options(note) -- adds the options
    #    process: "latex" | "none"
    #    collate: true | false
    options = %{mode: "show", username: conn.assigns.current_user.username, public: note.public} |> Note.add_options(note)
    rendered_text = String.trim(RenderText.transform(note.content, options))

    Utility.report("OPTIONS IN NOTE:SHOW", options)

    inserted_at= Note.inserted_at_short(note)
    updated_at= Note.updated_at_short(note)
    word_count = RenderText.word_count(note.content)

    sharing_is_authorized = true #  conn.assigns.current_user.id == note.user_id

    params1 = %{note: note, rendered_text: rendered_text,
                  inserted_at: inserted_at, updated_at: updated_at,
                  options: options, word_count: word_count,
                  sharing_is_authorized: sharing_is_authorized, current_id: note.id, channela: user.channel}


    conn_query_string = conn.query_string || ""
    if conn_query_string == "" do
      query_string = "index=0&id_string=#{note.id}"
    else
      query_string = conn_query_string
    end
    params2 = Note.decode_query_string(query_string)

    params = Map.merge(params1, params2)

    # {:ok, updated_at } = note.updated_at |> Timex.local |> Timex.format("{M}-{D}-{YYYY}")
    # IO.puts "UPDATED AT: #{updated_at}"
    render(conn, "show.html", params)
  end


  def do_show2(conn, note) do
      text = note.content
      lines =  String.split(String.trim(text), ["\n", "\r", "\r\n"])
      |> Enum.filter(fn(line) -> !Regex.match?(~r/^title/, line) end)
      first_line  = hd(lines)
      [id2, _] = String.split(first_line, ",")
      redirect(conn, to: "/show2/#{note.id}/#{id2}")
  end

  def show(conn, %{"id" => id}) do

    note = Note.get(id)

    if Enum.member?(note.tags, ":toc") do
      do_show2(conn, note)
    else
      do_show(conn, note)
    end

  end

  def show2(conn, %{"id" => id, "id2" => id2}) do

      IO.puts "UUU id = #{id}"
      IO.puts "UUU id2 = #{id2}"

      note = Note.get(id)
      note2 = Note.get(id2)
      user = Repo.get!(User, note.user_id)

      Note.update_viewed_at(note)

      # Note.add_options(note) -- adds the options
      #    process: "latex" | "none"
      #    collate: true | false
      options = %{mode: "show", username: conn.assigns.current_user.username, public: note.public} |> Note.add_options(note)
      options2 = %{mode: "show", username: conn.assigns.current_user.username, public: note.public} |> Note.add_options(note2)

      rendered_text = String.trim(RenderText.transform(note.content, options))
      rendered_text2 = String.trim(RenderText.transform(note2.content, options2))


      Utility.report("OPTIONS IN NOTE:SHOW", options)

      inserted_at= Note.inserted_at_short(note)
      updated_at= Note.updated_at_short(note)
      word_count = RenderText.word_count(note.content)

      sharing_is_authorized = true #  conn.assigns.current_user.id == note.user_id

      params1 = %{note: note, note2: note2, rendered_text: rendered_text, rendered_text2: rendered_text2,
                    inserted_at: inserted_at, updated_at: updated_at,
                    options: options, word_count: word_count,
                    sharing_is_authorized: sharing_is_authorized, current_id: note.id, channela: user.channel}


      conn_query_string = conn.query_string || ""
      if conn_query_string == "" do
        query_string = "index=0&id_string=#{note.id}"
      else
        query_string = conn_query_string
      end
      params2 = Note.decode_query_string(query_string)

      params = Map.merge(params1, params2)

      # {:ok, updated_at } = note.updated_at |> Timex.local |> Timex.format("{M}-{D}-{YYYY}")
      # IO.puts "UPDATED AT: #{updated_at}"
      render(conn, "show2.html", params)
    end

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

    new_content = Regex.replace(~r/ß/, note_params["content"], "") |> RenderText.preprocessURLs
    new_title = Regex.replace(~r/ß/, note_params["title"], "")

    tags = Tag.str2tags(note_params["tag_string"])

    new_params = Map.merge(note_params, %{"content" => new_content, "title" => new_title,
        "tags" => tags, "edited_at" => Timex.now})

    changeset = Note.changeset(note, new_params)
    current_user = conn.assigns.current_user
    changeset = Ecto.Changeset.update_change(changeset, :identifier, fn(ident) -> Note.normalize_identifier(current_user, ident) end)


    index = conn.params["index"]
    id_string = conn.params["id_string"]
    params = Note.decode_query_string("index=#{index}&id_string=#{id_string}")
    params = Map.merge(params, %{random: "no"})


    # rendered_text = RenderText.transform(new_content, %{collate: "no", mode: "show", process: "latex"})
    rendered_text = RenderText.transform(new_content, Note.add_options(%{mode: "show", public: note.public}, note))

    if save_option != "exit"  do
      params = params_for_save(conn, note, params, changeset, rendered_text)
    end


    Utility.report("CHANGESET 2", changeset)
    case Repo.update(changeset) do
      {:ok, note} ->
        if save_option == "exit" do
          conn
          # |> put_flash(:info, "Note updated successfully.")
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

    if ((user.read_only == false) and (note.user_id ==  user.id)) do
      doUpdate(note, note_params, save_option, conn)
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
       |> redirect(to: note_path(conn, :index, random: "no"))
    end
  end




end
