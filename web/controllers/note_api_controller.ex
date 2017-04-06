defmodule LookupPhoenix.NoteApiController do

   alias LookupPhoenix.NoteShowAction

   @moduledoc """
   API controller for LookupNote

   /note/:id -- return id, title, content, tag_string
"""

    use LookupPhoenix.Web, :controller
    use Timex

    alias LookupPhoenix.Note
    alias LookupPhoenix.User
    alias LookupPhoenix.Utility

    defp authenticated(conn) do
      kvps = conn.req_headers
      result =  Enum.filter(kvps, fn(pair) -> {k, v} = pair; k == "secret" end)
      [{_,secret}] = result
      secret == "abcdef9h5vkfR1Tj0U_1f!"
    end

    def show(conn, %{"id" => id}) do
      if authenticated(conn) do
         note = Note.get(id)
         query_string = conn.query_string
         username = "jxxcarlson"
         result = NoteShowAction.call(username, query_string, id)
         render conn, "note.json", result: result
       else
         render conn, "error.json", message: "darn it!"
      end
    end

end