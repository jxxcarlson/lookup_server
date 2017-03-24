defmodule LookupPhoenix.DynamicNotebook do

  alias LookupPhoenix.Note
  alias LookupPhoenix.Search
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility

  def dynamic_tag(note) do
    dyn_tags = note.tags
    |> Enum.filter(fn(tag) -> Regex.match?(~r/dynamic/, tag) end)
    cond do
      dyn_tags == [] -> nil
      true -> dyn_tags |> hd |> String.replace("dynamic:", "")
    end
  end

  def update(notebook_id) do
    master_note = Note.get(notebook_id)
    tag = dynamic_tag(master_note)

    entries = String.split(master_note.content, ["\n", "\r", "\n\r"])
    first_entry = hd(entries)

    updated_entries = Search.find_by_user_and_tag(master_note.user_id, tag)
    |> Enum.map(fn(entry) -> "#{entry.id}, #{entry.title}" end)
    updated_entries  = [first_entry | updated_entries]
    |> Enum.join("\n")

    params = %{"content" => updated_entries}
    changeset = Note.changeset(master_note, params)
    Repo.update(changeset)
  end

 # Return notes for user with given tag
    def find_most_recent_with_tag(user_id, tag) do
      Search.find_by_user_and_tag(user_id, tag)  |> Utility.last
    end

  def needs_update?(notebook_id) do
    master_note = Note.get(notebook_id)
    tag = dynamic_tag(master_note)
    if tag == nil do
      false
    else
      most_recent_note = find_most_recent_with_tag(master_note.user_id, tag)
      most_recent_note.updated_at > master_note.updated_at
    end
  end

  def auto_update(notebook) do
    if needs_update?(notebook.id) do
      update(notebook.id)
    end
  end

end