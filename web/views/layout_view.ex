defmodule LookupPhoenix.LayoutView do
  use LookupPhoenix.Web, :view

  def cookies(conn, cookie_name) do
       conn.cookies[cookie_name]
  end

  def link_name(conn) do
    cookie_name = "site"
    "/site/#{cookies(conn, cookie_name)}"
  end

end
