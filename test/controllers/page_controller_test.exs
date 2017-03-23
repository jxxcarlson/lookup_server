defmodule LookupPhoenix.PageControllerTest do
  use LookupPhoenix.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "www.lookupnote.io"
  end

end