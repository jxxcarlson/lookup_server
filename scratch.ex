if conn.assigns.current_user.admin == true do
           users = Repo.all(LookupPhoenix.User)
           render conn, "index.html", users: users
       else
           conn
           |> put_flash(:error, "Sorry, you do no have access to that page")
           |> redirect(to: page_path(conn, :index))
           |> halt
       end