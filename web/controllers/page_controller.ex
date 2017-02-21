defmodule LookupPhoenix.PageController do
  use LookupPhoenix.Web, :controller

  def index(conn, _params) do
    conn
      Plug.Conn.cookies(conn, "channel") > IO.puts
      # <%= Plug.Conn.cookies(@conn, "site") %>
      render conn, "index.html"
  end

  def tips(conn, _params) do
      render conn, "tips.html"
  end

  def demo(conn, _params) do
     render conn, "demo.html"
  end

end
