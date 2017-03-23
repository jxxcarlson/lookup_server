defmodule LookupPhoenix.DynamicNotebook do

  alias LookupPhoenix.Note
  alias LookupPhoenix.Search
  alias LookupPhoenix.Repo

  def update(notebook_id) do
    master_note = Note.get(notebook_id)
    tag = master_note.tags
    |> Enum.filter(fn(tag) -> Regex.match?(~r/dynamic/, tag) end)
    |> hd
    |> String.replace("dynamic:", "")

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

end