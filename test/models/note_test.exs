defmodule LookupPhoenix.NoteTest do
  use LookupPhoenix.ModelCase

  alias LookupPhoenix.Note

  @valid_attrs %{content: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Note.changeset(%Note{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Note.changeset(%Note{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "get note" do
    note = %Note{title: "Astrology", identifier: "jxxcarlson.bar"}
    {:ok, note} = Repo.insert(note)
    note2 = Note.get(note.id)
    assert note2 != nil
    assert Note.get(1) == nil
  end

  test "get parent, success" do
    parent_note = %Note{title: "Astrology", identifier: "jxxcarlson.bar"}
    {:ok, parent_note} = Repo.insert(parent_note)
    note = %Note{title: "Magick", parent_id: parent_note.id}
    assert note.parent_id == parent_note.id
    assert Note.get_parent(note) != nil
    assert Note.get_parent(note).title == "Astrology"
  end

  test "get parent, parent does not exist" do
    parent_note = %Note{title: "Astrology", identifier: "jxxcarlson.bar"}
    {:ok, parent_note} = Repo.insert(parent_note)
    note = %Note{title: "Magick", parent_id: 1}
    assert Note.get(1) == nil
    # assert Note.get_parent(note) == nil
  end

  test "get parent, failure" do
    note = %Note{title: "Magick", tags: ["foo", "baz"]}
    assert Note.get_parent(note) == nil
  end

end
