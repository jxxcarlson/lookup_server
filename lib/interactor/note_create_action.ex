defmodule LookupPhoenix.NoteCreateAction do

  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Search
  alias LookupPhoenix.Identifier
  alias LookupPhoenix.User
  alias LookupPhoenix.Tag

  alias LookupPhoenix.Utility

  def call(conn, note_params) do
     Utility.report("NoteCreateAction, params", note_params)
     changeset = setup(conn, note_params)
     case Repo.insert(changeset) do
        {:ok, note} ->
          [note.id] ++ Note.recall_list(conn.assigns.current_user.id)
          |> Note.memorize_list(conn.assigns.current_user.id)
          {:ok, conn, note }
        {:error, changeset} ->
          {:error, changeset: changeset}
      end
  end

  defp get_master_note_text(channel, tags) do
    master_notes = Enum.map(tags, fn(tag) -> "live:" <> tag end)
    |> Enum.map(fn(tag) -> Search.tag_search([tag], channel, :all) end)
    |> List.flatten
    if length(master_notes) == 1 do
      master_note = hd(master_notes)
      "xref::#{master_note.id}[#{master_note.title}]\n\n"
    else
      ""
    end
  end


  defp setup(conn, note_params) do
      [access, channel_name, user_id] = User.decode_channel(conn.assigns.current_user)
      [tag_string, tags] = get_tags(note_params, channel_name)
      master_note_text =  get_master_note_text(conn.assigns.current_user.channel, tags)

      content = note_params["content"] || " "
      title = note_params["title"] || "Untitled"

      title = cond do
        title == nil -> "Untitled"
        title == "" -> "Untitled"
        true -> title
      end

      content = cond do
        content == nil -> "Write note content here"
        content == "" -> "Write note content here"
        true -> content
      end

      new_content = master_note_text <> Regex.replace(~r/ß/, content, "")
      new_title = Regex.replace(~r/ß/, title, "")
      identifier = Identifier.make(conn.assigns.current_user.username, new_title)
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