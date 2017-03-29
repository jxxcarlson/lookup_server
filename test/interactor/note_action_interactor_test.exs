defmodule LookupPhoenix.NoteActionTest do

  use LookupPhoenix.ConnCase

  alias LookupPhoenix.Utility
  alias LookupPhoenix.User
  alias LookupPhoenix.Note
  alias LookupPhoenix.NoteAction
  alias LookupPhoenix.Utility

  test "list, default branch" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
    Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1"}
    qsMap = %{}
    result = NoteAction.list(user, qsMap)
    assert length(result.notes) == 1
  end

  test "list, channel branch, channel with no records" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
    note  = Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1"}
    Utility.report("IDS:", [user.id, note.user_id])
    qsMap = %{"channel" => "alpha.beta"}
    result = NoteAction.list(user, qsMap)
    assert length(result.notes) == 0
  end

  test "list, channel branch, channel mismatch" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.yada"})
    Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1",
      tags: ["poetry"]}
    qsMap = %{"channel" => "frodo.science"}
    result = NoteAction.list(user, qsMap)
    assert length(result.notes) == 0
  end

  test "list, channel branch, channel match" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.science"})
    note  = Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1",
      tags: ["science", "poetry"]}
    Utility.report("IDS:", [user.id, note.user_id])
    qsMap = %{"channel" => "frodo.science"}
    result = NoteAction.list(user, qsMap)
    assert length(result.notes) == 1
  end

end