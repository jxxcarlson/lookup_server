defmodule LookupPhoenix.AppState do

  alias LookupPhoenix.Utility

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
       search_history: nil}
  end

  def put(:user, id, record) do
    put("user.#{id}", record)
  end

  def get(:user, id) do
    get("user.#{id}")
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

  ## Existing API

  def memorize_notes(note_list, user_id) do
    note_list
    |> Enum.map(fn(note) -> note.id end)
    # |> memorize_list(user_id)
    update(:user, user_id, :search_history, note_list)
    note_list
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