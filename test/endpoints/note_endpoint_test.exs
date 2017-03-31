defmodule LookupPhoenix.NoteControllerTest do
  use LookupPhoenix.ConnCase

  alias LookupPhoenix.Note
  alias LookupPhoenix.User
  # alias LookupPhoenix.Identifier
  alias LookupPhoenix.Search


  @valid_attrs %{content: "some content", title: "some content"}
  # @invalid_attrs %{}

  setup do
     # user = Repo.insert!(%User{email: "yumpa@foo.io", password: "somepassword", username: "yumpa", channel: "yumpa:all"})
     # note = Repo.insert! %Note{user_id: user.id, title: "foobar", content: "Test", identifier: "yada_yada"}
     {:ok, conn: put_req_header(build_conn(), "accept", "application/html")}
  end


  test "test index" do
      user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
      assert user.channel == "frodo.all"
      Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1"}
      all_notes = Note
        |> NoteSearch.for_user(user.id)
        |> Repo.all
      assert length(all_notes) == 1
      conn = build_conn()
       |> assign(:current_user, user)
       |> get("/notes?mode=all")

      # body = conn |> response(200) |> Poison.decode!

      assert html_response(conn, 200) =~ "Magical"
  end

  test "renders form for new resources", %{conn: conn} do
      user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
      assert user.channel == "frodo.all"
      Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1"}

      conn = build_conn()
       |> assign(:current_user, user)
       |> get("/notes/new")

      assert html_response(conn, 200) =~ "New note"
  end


  test "creates resource", %{conn: conn} do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
    note = Repo.insert! %Note{user_id: user.id, title: "Magical", content: "Test", identifier: "frodo.1"}
    conn = build_conn()
      |> assign(:current_user, user)
      |> put("/notes/#{note.id}")

    # assert Repo.get_by(Note, @valid_attrs)
  end



end
