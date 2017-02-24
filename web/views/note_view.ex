defmodule LookupPhoenix.NoteView do
  use LookupPhoenix.Web, :view

  def cookies(conn, cookie_name) do
     conn.cookies[cookie_name]
  end

end
