defmodule LookupPhoenix.NoteCreateAction do

  alias LookupPhoenix.Note
  alias LookupPhoenix.Search
  alias LookupPhoenix.Identifier
  alias LookupPhoenix.User
  alias LookupPhoenix.Tag

  def call(conn, note_params) do
     changeset = setup(conn, note_params)
     result = %{changeset: changeset}
  end

  defp master_note_text(channel, tags) do
    master_notes = Enum.map(tags, fn(tag) -> "live:" <> tag end)
    |> Enum.map(fn(tag) -> Search.tag_search([tag], channel, :all) end)
    |> List.flatten
    if length(master_notes) == 1 do
      IO.puts "MASTER NOTE IS #{hd(master_notes).title}"
      master_note = hd(master_notes)
      "xref::#{master_note.id}[#{master_note.title}]\n\n"
    else
      IO.puts "NO MASTER NOTE"
      ""
      nil
    end
  end

  defp setup(conn, note_params) do
      [access, channel_name, user_id] = User.decode_channel(conn.assigns.current_user)
      [tag_string, tags] = get_tags(note_params, channel_name)
      master_note_text =  master_note_text(conn.assigns.current_user.channel, tags)
      new_content = master_note_text <> Regex.replace(~r/ß/, note_params["content"], "")
      new_title = Regex.replace(~r/ß/, note_params["title"], "")
      identifier = Identifier.make(conn.assigns.current_user.username, new_title)
      IO.puts "In create note, identifier = #{identifier}"
      new_params = %{"content" => new_content, "title" => new_title,
         "user_id" => conn.assigns.current_user.id, "viewed_at" => Timex.now, "edited_at" => Timex.now,
         "tag_string" => tag_string, "tags" => tags, "public" => false, "identifier" => identifier}
      Note.changeset(%Note{}, new_params)
  end

  defp get_tags(note_params, channel_name) do

      # Normalize tag_string name and ensure that is non-nil and non-empty
      tag_string = note_params["tag_string"] || ""
      if is_nil(channel_name) do channel_name = "all" end

      cond  do
        !Enum.member?(["all", "public"], channel_name) and tag_string != "" ->
          tag_string = [tag_string, channel_name] |> Enum.join(", ")
        !Enum.member?(["all", "public"], channel_name) and tag_string == ""  ->
          tag_string = channel_name
        tag_string == "" -> tag_string = "-"
        tag_string != "" -> tag_string
      end

      tags = Tag.str2tags(tag_string)

      [tag_string, tags]
  end

end