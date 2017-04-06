defmodule LookupPhoenix.NoteShowActionTest do

    use LookupPhoenix.ConnCase

    alias LookupPhoenix.Utility
    alias LookupPhoenix.User
    alias LookupPhoenix.Note
    alias LookupPhoenix.NoteShowAction
    alias LookupPhoenix.Utility


  test "Ensure that rendered text is returned" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
    note = Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1"}
    result = NoteShowAction.call("frodo", nil, note.id)
    assert result.rendered_text =~ "Test"
    assert result.title == "Magical"
  end

end