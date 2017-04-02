defmodule LookupPhoenix.NoteIndexActionTest do

  use LookupPhoenix.ConnCase

  alias LookupPhoenix.Utility
  alias LookupPhoenix.User
  alias LookupPhoenix.Note
  alias LookupPhoenix.NoteIndexAction
  alias LookupPhoenix.Utility

  test "list, default branch" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
    Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1"}
    conn = build_conn()
           |> assign(:current_user, user)
           |> get("/notes")
    result = NoteIndexAction.call(conn)
    assert length(result.notes) == 1
  end

  test "list, channel branch, channel with no records" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
    note  = Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1", tags: ["foo"]}
    conn = build_conn()
           |> assign(:current_user, user)
           |> get("/notes?channel=alpha.beta")
    result = NoteIndexAction.call(conn)
    assert length(result.notes) == 0
  end

  test "list, channel branch, channel mismatch" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.yada"})
    Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1",
      tags: ["poetry"]}
    qsMap = %{"channel" => "frodo.science"}
    conn = build_conn()
           |> assign(:current_user, user)
           |> get ("notes/?channel=frodo.science")
    result = NoteIndexAction.call(conn)
    assert length(result.notes) == 0
  end

  test "list, channel branch, channel match" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.science"})
    note  = Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1",
      tags: ["science", "poetry"]}
    conn = build_conn()
           |> assign(:current_user, user)
           |> get ("notes/?channel=frodo.science")
    result = NoteIndexAction.call(conn)
    assert length(result.notes) == 1
  end

end