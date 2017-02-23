defmodule LookupPhoenix.PublicController do
  use LookupPhoenix.Web, :controller
    alias LookupPhoenix.Note
    alias LookupPhoenix.User
    alias LookupPhoenix.Utility
    alias LookupPhoenix.Search


   def share(conn, %{"id" => id}) do
         note  = Repo.get!(Note, id)
         token = conn.query_string
         Utility.report("id", id)
         Utility.report("token", token)
         user = Repo.get(User, note.user_id)
         site = user.username

         options = %{mode: "show", process: "none"}
         params = %{note: note, site: site, options: options}

         Utility.report("[note.public, note.shared]", [note.public, note.shared])

         case [note.public, note.shared] do
            [true, _] -> render(conn, "share.html", params) |> put_resp_cookie("site", site)
            [_, true] ->
               if Note.match_token_array(token, note) do render(conn, "share.html", params) end
            _ ->  render(conn, "error.html", params) |> put_resp_cookie("site", site)
          end

     end



  def show(conn, %{"id" => id, "site" => site}) do
      note  = Repo.get(Note, id)
      token = conn.query_string
      Utility.report("token", token)

      if note == nil do
          render(conn, "error.html", %{})
      else
         if Enum.member?(note.tags, "latex") do
            options = %{mode: "show", process: "latex"}
          else
            options = %{mode: "show", process: "none"}
          end
          params1 = %{note: note, options: options, site: site}
          params2 = Note.decode_query_string(conn.query_string)
          params = Map.merge(params1, params2)

          case note.public do
            true -> render(conn, "show.html", Map.merge(params, %{title: "LookupNotes: Public"})) |> put_resp_cookie("site", site)
            false ->
               if Note.match_token_array(token, note) do
                 render(conn, "show.html", Map.merge(params, %{title: "LookupNotes: Shared"})) |> put_resp_cookie("site", site)
               else
                 render(conn, "error.html", params)
               end
          end
      end
      # match_token_array
  end

  # def index(conn, %{"site" => site}) do
  def index(conn, params) do
    # Utility.report('CONN . ASSIGNS', conn.request_path)

    IO.puts "conn.request_path = #{conn.request_path}"

    site = params["site"]
    channel = "demo.public"
    if conn.assigns.current_user != nil do
      User.set_channel( conn.assigns.current_user, channel)
      IO.puts "I HAVE SET YOUR CHANNEL TO #{channel}"
    end
    note_record = Search.notes_for_channel(channel, %{})
    notes = Utility.add_index_to_maplist(note_record.notes)
    id_string = Note.extract_id_list(notes)
    params = %{site: site, notes: notes, note_count: length(notes), id_string: id_string}
    conn
      |> put_resp_cookie("channel", channel)
      |> put_resp_cookie("site", site)
      |> render("index.html", params)
  end

  def site(conn, params) do
     site = params["data"]["site"]
     IO.puts "site = #{site}"
     conn |> redirect(to: "/site/#{site}")

  end


end
