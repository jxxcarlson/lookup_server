defmodule LookupPhoenix.PublicController do
  use LookupPhoenix.Web, :controller
    alias LookupPhoenix.Note
    alias LookupPhoenix.User
    alias LookupPhoenix.Utility


  def show(conn, %{"id" => id}) do
      note  = Repo.get(Note, id)
      if note == nil do
          render(conn, "error.html", %{})
      else
          options = %{mode: "show", process: "none"}
          params = %{note: note, options: options}
          if note.public do
            render(conn, "show.html", params)
          else
            render(conn, "error.html", params)
          end
      end


  end

end
