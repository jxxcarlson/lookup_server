defmodule LookupPhoenix.AppState do

  alias LookupPhoenix.Utility
  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo
  alias LookupPhoenix.NoteSearch

  ## Base API

  def put(key, value) do
    Mnemonix.put(Cache, key, value)
  end

  def get(key) do
    Mnemonix.get(Cache, key)
  end

  ## User API

  def initial_record() do
     %{current_note: nil, current_notebook: nil,
       search_history: [], toc_history: []}
  end

  def put(:user, id, record) do
    put("user.#{id}", record)
  end

  def get(:user, id) do
    record = get("user.#{id}") || initial_record()
#    if record.current_note == nil do
#      note = Note |> NoteSearch.for_user(id) |> NoteSearch.limit(1) |> Repo.one
#      update(:user, id, :current_note, note.id)
#    end
  end

  def get(:user, id, key) do
    get("user.#{id}")[key]
  end

  def update(:user, id, key, value) do
    record = get(:user, id)
    if record == nil do record = initial_record() end
    record = %{ record | key => value }
    put(:user, id, record)
  end

  def update({:user, user_id, :search_history, note_id}) do
    Utility.report("NC . UPDATE . note_id", note_id)
    if !is_number(note_id) do note_id = String.to_integer(note_id) end
    sh = get(:user, user_id, :search_history)
    if !Enum.member?(sh, note_id) do
      new_search_history = [note_id|sh]
      update(:user, user_id, :search_history, new_search_history)
    else
      new_search_history = sh
    end
      new_search_history
  end

  ## Existing API

  def memorize_notes(note_list, user_id) do
    id_list = note_list |> Enum.map(fn(note) -> note.id end)
    # |> memorize_list(user_id)
    update(:user, user_id, :search_history, id_list)
    id_list
  end

  def memorize_list(id_list, user_id) do
    new_id_list = Enum.filter(id_list, fn x -> is_integer(x) end)
    update(:user, user_id, :search_history, id_list)
    # put( "active_notes_#{user_id}", new_id_list)
  end

  def recall_list(user_id) do
    # recalled = get("active_notes_#{user_id}")
    recalled = get(:user, user_id, :search_history)
    if recalled == nil do
       []
    else
       recalled |> Enum.filter(fn x -> is_integer(x) end)
    end
  end


end