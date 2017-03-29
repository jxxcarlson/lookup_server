defmodule LookupPhoenix.NoteIndexAction do

  alias LookupPhoenix.Search
  alias LookupPhoenix.User
  alias LookupPhoenix.Utility

  def call(current_user, qsMap) do
    note_record = list(current_user, qsMap)
    note_count_string = get_note_count_string(note_record, qsMap)
    %{note_record: note_record, note_count_string: note_count_string}
  end

  defp list(current_user, qsMap) do

    channel = current_user.channel
      [channel_name, _] = String.split(channel, ".")
      if channel_name = current_user.username do
        access = :all
      else
        access = :public
      end

     Utility.report("qsMap", qsMap)

    cond do
       qsMap["channel"] != nil ->
         IO.puts "CHANNEL BRANCH"
         channel = qsMap["channel"]
         channel_username = hd(String.split(channel, "."))
         User.update_channel(current_user, channel)
         if channel_username == current_user.username do
           ch_options = %{access: :all}
         else
           ch_options = %{access: :public}
         end
         note_record = Search.notes_for_channel(channel, ch_options)
       qsMap["random"] == "one"  ->
         IO.puts "RANDOM ONE BRANCH"
         note_record = Search.notes_for_channel(current_user.channel, %{})
         note = note_record.notes |> Utility.random_element
         notes = [note]
         n = length(notes)
         note_record = %{notes: notes, note_count: n, original_note_count: n}
       qsMap["random"] == "many"  ->
         IO.puts "RANDOM MANY BRANCH"
         note_record = Search.notes_for_channel(current_user.channel, %{})
         notes = note_record.notes |> Enum.shuffle |> Enum.slice(0..19)
         n = length(notes)
         note_record = %{notes: notes, note_count: n, original_note_count: n}
       qsMap["tag"] != nil  ->
         IO.puts "TAG BRANCH"
         notes = Search.tag_search([qsMap["tag"]], channel, access)
         n = length(notes)
         note_record = %{notes: notes, note_count: n, original_note_count: n}
       true ->
         IO.puts "DEFAULT BRANCH"
         if channel_name == current_user.username do
           ch_options = %{access: :all}
         else
           ch_options = %{access: :public}
         end
         note_record = Search.notes_for_channel(channel, ch_options)
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
