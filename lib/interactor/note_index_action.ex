defmodule LookupPhoenix.NoteIndexAction do

  alias LookupPhoenix.Note
  alias LookupPhoenix.Search
  alias LookupPhoenix.User
  alias LookupPhoenix.Utility

  def call(conn) do
    current_user = conn.assigns.current_user
    IO.puts "conn, query_string = #{conn.query_string}"
    qsMap = Utility.qs2map(conn.query_string)
    Utility.report("conn, qsMap", qsMap)
    list(current_user, qsMap)
  end

  defp list(current_user, qsMap) do

    note_record = cond do
       qsMap["channel"] != nil ->
         handle_channel_request(current_user, qsMap)
       qsMap["random"] == "one"  ->
         handle_random_one_request(current_user, qsMap)
       qsMap["random"] == "many"  ->
         handle_random_many_request(current_user, qsMap)
       qsMap["tag"] != nil  ->
         handle_tag_request(current_user, qsMap)
       true ->
         handle_default_request(current_user, qsMap)
     end

     options = %{mode: "index", process: "none"}
     notes = Utility.add_index_to_maplist(note_record.notes)
     id_string = Note.extract_id_list(notes)
     note_count_string = ""

     if qsMap["set_channel"] == nil do
       branch = "site"
     else
       branch = "standard"
     end

     %{branch: branch, note_record: note_record, notes: notes,
        id_string: id_string, noteCountString: note_count_string}
  end

  defp handle_channel_request(current_user, qsMap) do
     IO.puts "CHANNEL BRANCH"
     channel = qsMap["channel"]
     channel_username = hd(String.split(channel, "."))
     User.update_channel(current_user, channel)
     [_, access] = channel_access(current_user)
     Search.notes_for_channel(channel, access)
  end

  defp handle_random_one_request(current_user, qsMap) do
      IO.puts "RANDOM ONE BRANCH"
     [channel, access] = channel_access(current_user)
      note_record = Search.notes_for_channel(current_user.channel,access)
      note = note_record.notes |> Utility.random_element
      notes = [note]
      n = length(notes)
      %{notes: notes, note_count: n, original_note_count: n}
  end

  defp handle_random_many_request(current_user, qsMap) do
     IO.puts "RANDOM MANY BRANCH"
    [channel, access] = channel_access(current_user)
     note_record = Search.notes_for_channel(channel, access)
     notes = note_record.notes |> Enum.shuffle |> Enum.slice(0..19)
     n = length(notes)
     %{notes: notes, note_count: n, original_note_count: n}
  end

  defp handle_tag_request(current_user, qsMap) do
    IO.puts "TAG BRANCH"
    [channel, access] = channel_access(current_user)
    notes = Search.tag_search([qsMap["tag"]], channel, access)
    n = length(notes)
    %{notes: notes, note_count: n, original_note_count: n}
  end

  defp handle_default_request(current_user, qsMap) do
    IO.puts "DEFAULT BRANCH"
    [channel, access] = channel_access(current_user)
    Search.notes_for_channel(channel, access)
  end

  defp channel_access(current_user) do
    channel = current_user.channel
    IO.puts "channel_access, channel = #{channel}"
    [channel_name, _] = String.split(channel, ".")
    if channel_name == current_user.username do
      [channel, %{access: :all}]
    else
      [channel, %{access: :public}]
    end
  end


  defp get_note_count_string(note_record, qsMap) do

        cond do
          qsMap["random"] == "one" -> infix = "random"
          qsMap["random"] == "many"  -> infix = "random"
          true -> infix = ""
        end

       if note_record.original_note_count > note_record.note_count do
         if note_record.original_note_count == 1 do
           _notes = "note"
         else
           _notes = "notes"
         end
         noteCountString = "#{note_record.note_count} Random #{_notes} from #{note_record.original_note_count}"
       else
         if note_record.note_count == 1 do
           _notes = "Note"
         else
           _notes = "Notes"
         end
         noteCountString = "#{note_record.note_count} #{infix} #{_notes}"
       end
  end

end
