defmodule MU.LiveNotebook do

  alias LookupPhoenix.Note
  alias LookupPhoenix.NoteSearch
  alias LookupPhoenix.User
  alias LookupPhoenix.Search
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Utility

  # return nil if there are no tags of the form live:IDENTIFIER,
  # otherwise return IDENTIFIER of first such tag (there should be only one).
  def live_tag(note) do
    live_tags = note.tags
    |> Enum.filter(fn(tag) -> Regex.match?(~r/live/, tag) end)
    cond do
      live_tags == [] -> tag = nil
      true -> tag = live_tags |> hd |> String.replace("live:", "")
    end
    tag
  end

  def process(entry) do
    [text, tags] = entry
    headings = tags |> Enum.filter(fn(tag) -> Regex.match?(~r/^heading/, tag) end)
    cond do
      headings == [] -> [text]
      true ->
        heading = hd(headings)
        [_, title] = String.split(heading, ":")
        IO.puts "headning above #{text} = #{title}"
        ["title, #{title}", text]
    end
  end

  def put_headings(entries) do
    Enum.reduce(entries, [], fn(entry, acc) -> acc ++ process(entry) end)
  end

  def update(master_note) do
    master_note_user = Repo.get!(User, master_note.user_id)
    tag = "parent:#{master_note.identifier}"

    entries = String.split(master_note.content, ["\n", "\r", "\n\r"])
    first_entry = hd(entries)

    updated_entries = Note
      |> NoteSearch.select_by_user_and_tag(master_note_user, tag)
      |> NoteSearch.sort_by_created_at
      |> Repo.all
      |> Enum.map(fn(entry) -> ["#{entry.id}, #{entry.title}", entry.tags] end)
      |> put_headings
    updated_entries  = [first_entry | updated_entries]
    |> Enum.join("\n")

    params = %{"content" => updated_entries}
    changeset = Note.changeset(master_note, params)
    Repo.update(changeset)
  end

 # Return notes for user with given tag
    def find_most_recent_with_tag(user_id, tag) do
      user = Repo.get!(User, user_id)
      Note
       |> NoteSearch.select_by_user_and_tag(user, tag)
       |> Repo.all
       |> Utility.last
    end

  def needs_update?(master_note) do
    if Enum.member?(master_note.tags, ":live_notebook") != nil do
      IO.puts "#{master_note.title} is a LIVE NOTEBOOK"
      # owner = User.find master_note.user_id
      tag = "parent:#{master_note.identifier}"
      most_recent_note = find_most_recent_with_tag(master_note.user_id, tag)
      cond do
        most_recent_note == nil -> false
        true -> most_recent_note.updated_at > master_note.updated_at
      end
    end
  end

  def auto_update(notebook) do
    IO.puts "======== auto_update ========"
    IO.puts "Notebook #{notebook.title}, id = #{notebook.id}"
    IO.puts "======== auto_update ========"
    if needs_update?(notebook) do
      update(notebook)
    end
  end

end