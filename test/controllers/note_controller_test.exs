defmodule LookupPhoenix.NoteControllerTest do
  use LookupPhoenix.ConnCase

  alias LookupPhoenix.Note
  alias LookupPhoenix.User
  alias LookupPhoenix.Identifier
  alias LookupPhoenix.Search


  @valid_attrs %{content: "some content", title: "some content"}
  @invalid_attrs %{}

  setup do
     user = Repo.insert!(%User{email: "yumpa@foo.io", password: "somepassword", username: "yumpa", channel: "yumpa:all"})
     note = Repo.insert! %Note{user_id: user.id, title: "foobar", content: "Test", identifier: "yada_yada"}
     {:ok, conn: put_req_header(build_conn(), "accept", "application/html")}
  end

  test "endpoint index text" do
      user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
      assert user.channel == "frodo.all"
      note = Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1"}
      all_notes = Search.all_notes_for_user(:all, user)
      assert length(all_notes) == 1
      conn = conn()
       |> assign(:current_user, user)
       |> get("/notes?mode=all")

      # body = conn |> response(200) |> Poison.decode!

      assert html_response(conn, 200) =~ "Magical"
  end


  test "require authentication for these actions", %{conn: conn} do
    Enum.each([
       get(conn, note_path(conn, :new)),
       get(conn, note_path(conn, :create. %{}))
    ], fn conn -> assert html_response(conn, 302); assert conn.halted end)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, note_path(conn, :index)
    IO.puts "HTML RESPONSE: #{html_response(conn, 200)}"
    assert html_response(conn, 200) =~ "Listing notes"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, note_path(conn, :new)
    assert html_response(conn, 200) =~ "New note"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, note_path(conn, :create), note: @valid_attrs
    assert redirected_to(conn) == note_path(conn, :index)
    assert Repo.get_by(Note, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, note_path(conn, :create), note: @invalid_attrs
    assert html_response(conn, 200) =~ "New note"
  end

  test "shows chosen resource", %{conn: conn} do
   #  note = Repo.insert! %Note{}
   note = Note.get("yada_yada")
   assert note.title == "foobar"
    conn = get conn, note_path(conn, :show, note)
    assert html_response(conn, 200) =~ "Show note"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, note_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    note = Repo.insert! %Note{}
    conn = get conn, note_path(conn, :edit, note)
    assert html_response(conn, 200) =~ "Edit note"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    note = Note.get("yada_yada")
    assert note.title == "foobar"
    conn = put conn, note_path(conn, :update, note), note: @valid_attrs
    assert redirected_to(conn) == note_path(conn, :show, note)
    assert Repo.get_by(Note, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    note = Repo.insert! %Note{}
    conn = put conn, note_path(conn, :update, note), note: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit note"
  end

  test "deletes chosen resource", %{conn: conn} do
    note = Note.get("yada_yada")
    assert note.title == "foobar"
    user = Repo.insert! %User{read_only: false, username: "yumpa", email: "yumpa@foo.io"}
    conn = delete conn, note_path(conn, :delete, note)
    assert redirected_to(conn) == note_path(conn, :index)
    refute Repo.get(Note, note.id)
  end
end
