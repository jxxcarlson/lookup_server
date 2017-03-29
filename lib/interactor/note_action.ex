defmodule LookupPhoenix.NoteAction do

  alias LookupPhoenix.Search
  alias LookupPhoenix.User
  alias LookupPhoenix.Utility

  def list(current_user, qsMap) do

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

end
