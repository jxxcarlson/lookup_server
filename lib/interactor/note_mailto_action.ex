defmodule LookupPhoenix.NoteMailtoAction do

  alias LookupPhoenix.Note
  alias LookupPhoenix.Repo
  alias LookupPhoenix.NoteNavigation
  alias LookupPhoenix.TokenManager

  def call(conn, %{"id" => id}) do

    params2 = NoteNavigation.get(conn.query_string)
    note = Repo.get!(Note, id)
    message_part_1 = "This note is courtesy of http://www.lookupnote.io\n\n"
    message_part_2= "It is available at http://www.lookupnote.io/share/"
    message_part_4 = "\n\n\n------\nIf you wish to sign up for an account on lookupnote.io,\n please use this registation code: student "

    if note.identifier == nil do
      note_id = note.id
    else
      note_id = note.identifier
    end

    if note.public == false do
      token_record = TokenManager.generate_time_limited_token(note, 10, 240)
      message_part_3= "#{note_id}?#{token_record.token}"
    else
      message_part_3= "#{note_id}"
    end

    email_body = message_part_1 <> message_part_2 <> message_part_3 <> message_part_4
          |> String.replace("\n", "%0D%0A")

    params1 = %{note: note, email_body: email_body}

    params = Map.merge(params1, params2)
    %{params: params}
  end
end