# require IEx

defmodule LookupPhoenix.SearchController do
    use LookupPhoenix.Web, :controller
    alias LookupPhoenix.Note
    alias LookupPhoenix.User
    alias LookupPhoenix.Utility


    def index(conn, %{"search" => %{"query" => query}}) do


      User.increment_number_of_searches(conn.assigns.current_user)

      queryList = String.split(query)
      notes = LookupPhoenix.Note.search(queryList, conn.assigns.current_user.id)
      LookupPhoenix.Note.memorize_notes(notes, conn.assigns.current_user.id)

      notes = Utility.add_index_to_maplist(notes)
      id_string = Note.extract_id_list(notes)

      noteCount = length(notes)
      case noteCount do
        1 -> noteCountString = "1 Note found"
        _ -> noteCountString = Integer.to_string(noteCount) <> " Notes found"
      end

      render(conn, "index.html", notes: notes, id_list: id_string, noteCountString: noteCountString)


    end

    def tag_search(conn, %{"query" => query}) do

         IO.puts "THIS IS TAG SEARCH, query = #{query} ................."

          User.increment_number_of_searches(conn.assigns.current_user)

          queryList = String.split(query)

          notes = Note.tag_search(queryList, conn.assigns.current_user.id)

          Note.memorize_notes(notes, conn.assigns.current_user.id)

          notes = Utility.add_index_to_maplist(notes)
          id_string = Note.extract_id_list(notes)

          noteCount = length(notes)
          case noteCount do
            1 -> noteCountString = "1 Note found with tag #{query}"
            _ -> noteCountString = Integer.to_string(noteCount) <> " Notes found with tag #{query}"
          end

          render(conn, "index.html", notes: notes, id_list: id_string, noteCountString: noteCountString)


     end

     def tag_search1(conn, %{"query" => query}) do

               User.increment_number_of_searches(conn.assigns.current_user)

               queryList = String.split(query)

               notes = LookupPhoenix.Note.search(queryList, conn.assigns.current_user.id)
               LookupPhoenix.Note.memorize_notes(notes, conn.assigns.current_user.id)

               noteCount = length(notes)
               case noteCount do
                 1 -> noteCountString = "1 Note found with tag #{query}"
                 _ -> noteCountString = Integer.to_string(noteCount) <> " Notes found with tag #{query}"
               end

               render(conn, "index.html", notes: notes, noteCountString: noteCountString)


      end


    def random(conn, _params) do
         User.increment_number_of_searches(conn.assigns.current_user)
         expected_number_of_entries = 14
         # note_count = Note.count_notes_user(conn.assigns.current_user.id)
         user_id = conn.assigns.current_user.id
         note_count = Note.count_for_user(user_id)

         cond do
           note_count > 14 ->
              p = (100*expected_number_of_entries) / note_count
              notes = LookupPhoenix.Note.random_notes_for_user(p, conn.assigns.current_user.id)
           note_count <= 14 ->
              notes = Note.notes_for_user(user_id)
         end
         LookupPhoenix.Note.memorize_notes(notes, conn.assigns.current_user.id)

         notes = Utility.add_index_to_maplist(notes)
         id_string = Note.extract_id_list(notes)

         case note_count do
           1 -> countReportString =   "1 Random note"
           _ -> countReportString = "#{length(notes)} Random notes"
         end
         render(conn, "index.html", notes: notes, id_list: id_string, noteCountString: countReportString)
    end

   def recent(conn, params) do
        User.increment_number_of_searches(conn.assigns.current_user)
        hours_before = String.to_integer params["hours_before"]
        mode = params["mode"]
        user_id = conn.assigns.current_user.id

        case mode do
          "updated" ->
             notes = Note.updated_before_date(hours_before, Timex.now, user_id)
             update_message = "Recently updated"
          "viewed" ->
             notes = Note.viewed_before_date(hours_before, Timex.now, user_id)
             update_message = "Recently viewed"
        end



        note_count = length(notes)
        Note.memorize_notes(notes, conn.assigns.current_user.id)

        notes = Utility.add_index_to_maplist(notes)
        id_string = Note.extract_id_list(notes)

        case note_count do
           1 -> countReportString =   "1 #{update_message} note"
           _ -> countReportString = "#{length(notes)} #{update_message} notes"
        end
        render(conn, "index.html", notes: notes, id_list: id_string, noteCountString: countReportString)
   end


end



