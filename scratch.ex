
  test "creates resource and redirects when data is valid", %{conn: conn} do
    user = Repo.insert!(%User{email: "frodo@foo.io", password: "somepassword", username: "frodo", channel: "frodo.all"})
    conn = build_conn()
      |> assign(:current_user, user)
      |> post("/notes/")


    conn = post conn, note_path(conn, :create), note: @valid_attrs
    assert redirected_to(conn) == note_path(conn, :index)
    assert Repo.get_by(Note, @valid_attrs)
  end
