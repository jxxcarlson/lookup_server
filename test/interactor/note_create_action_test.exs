defmodule LookupPhoenix.NoteCreateActionTest do

  use LookupPhoenix.ConnCase

  alias LookupPhoenix.Utility
  alias LookupPhoenix.User
  alias LookupPhoenix.Note
  alias LookupPhoenix.NoteCreateAction
  alias LookupPhoenix.Utility

  test "create basic document" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
    # Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1"}
    params = %{"title" => "Test document", "content" => "This is a test"}
    conn = build_conn()
           |> assign(:current_user, user)
    result = NoteCreateAction.call(conn, params)

  end

end