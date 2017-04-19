defmodule LookupPhoenix.NoteApiController do

   use LookupPhoenix.Web, :controller
   use Timex

   alias LookupPhoenix.Note
   alias LookupPhoenix.NoteNavigation
   alias LookupPhoenix.User
   alias LookupPhoenix.AppState
   alias LookupPhoenix.Utility

   alias LookupPhoenix.NoteShowAction
   alias LookupPhoenix.NoteUpdateAction

   LookupPhoenix.JSONMapBuilder

   @moduledoc """
   API controller for LookupNote

   /note/:id -- return id, title, content, tag_string
"""

    defp key2value(list, key) do
      pair =  Enum.filter(list, fn(pair) -> {k, v} = pair; k == key end)
      [{_,value}] = pair
      value
    end

    defp conn2value(conn, key) do
      key2value(conn.req_headers, key)
    end

   defp authenticated(secret) do
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

    def update(conn, %{"id" => id, "put" => data}) do

#      Utility.report("conn", conn)
#      current_user = conn.assigns.current_user
#      IO.puts("API . UPDATE, CURRENT USER = #{current_user.id}")

      if authenticated(data["secret"]) do
         IO.puts "AUTHORIZED!"
         title = data["title"]
         username = data["username"]
         user = User.find_by_username(username)
         note = Note.get(id)
         id_list = AppState.update({:user, user.id, :search_history, note.id})
         navigation_data = NoteNavigation.get(id_list, id)
         params = Map.merge(data, %{nav: navigation_data})

         result = NoteUpdateAction.call(username, note, params)
         {status, note} = result.update_result
         IO.puts "update status = #{status}"
         params = Map.merge(%{note: note, nav: result.nav}, result.params)
         render conn, "note.json", result: params
       else
        render conn, "error.json", message: "darn it!"
      end
    end

end