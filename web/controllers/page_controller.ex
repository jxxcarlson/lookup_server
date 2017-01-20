defmodule LookupPhoenix.PageController do
  use LookupPhoenix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def tips(conn, _params) do
      render conn, "tips.html"
  end

  def demo(conn, _params) do
     render conn, "demo.html"
  end

end
