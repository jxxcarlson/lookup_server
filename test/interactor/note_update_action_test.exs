defmodule LookupPhoenix.NoteUpdateActionTest do

    use LookupPhoenix.ConnCase

    alias LookupPhoenix.Utility
    alias LookupPhoenix.User
    alias LookupPhoenix.Note
    alias LookupPhoenix.NoteUpdateAction
    alias LookupPhoenix.Utility


  test "Ensure that rendered text is updated" do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
    note = Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1"}
    params = %{:nav => %{channel: "PUBLIC", current_id: "#{note.id}", first_id: "#{note.id}",
                 first_index: 0, id_list: ["#{note.id}"], id_string: "#{note.id}", index: 0,
                 last_id: "#{note.id}", last_index: 0, next_id: "#{note.id}", next_index: 0, note_count: 1,
                 previous_id: "#{note.id}", previous_index: 0},
               "content" => "test\r\n\r\nWhat is 2 + 2?\r\n\r\nanswer:[2 + 2 = 4]\r\n\r\nabc",
               "identifier" => "jxxcarlson.abc.1",
               "idx" => "-1",
               "public" => "false",
               "tag_string" => "test",
               "title" => "ABC"}
    result = NoteUpdateAction.call("frodo", note, params)
    Utility.report("result.nav", result.nav)
    Utility.report("result.update_result", result.update_result)
    Utility.report("result.params", result.params)
    Utility.report("KEYS", Map.keys(result))
    # Utility.report("KEYS FOR update result", Map.keys(result.update_result))
   Utility.report("KEYS FOR nav", Map.keys(result.nav))

    assert result.params.rendered_text =~ "2 + 2"
    {:ok, note} = result.update_result
    assert note.title == "ABC"
  end

end