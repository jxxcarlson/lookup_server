defmodule LookupPhoenix.NoteCreateAction do

  alias LookupPhoenix.Note
  alias LookupPhoenix.Identifier
  alias LookupPhoenix.User
  alias LookupPhoenix.Tag

  def call(conn, note_params) do
     changeset = setup(conn, note_params)
     result = %{changeset: changeset}
  end

  defp setup(conn, note_params) do
      [access, channel_name, user_id] = User.decode_channel(conn.assigns.current_user)
      [tag_string, tags] = get_tags(note_params, channel_name)
      new_content = Regex.replace(~r/ß/, note_params["content"], "")
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