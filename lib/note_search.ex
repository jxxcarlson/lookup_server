defmodule LookupPhoenix.NoteSearch do
   use LookupPhoenix.Web, :model

   alias LookupPhoenix.User
   alias LookupPhoenix.Utility

 #### SEARCH AND SORT -- COMPOSABLE QUERIES ####

    # https://blog.drewolson.org/composable-queries-ecto/

    def for_user(query, user_id) do
      from n in query,
        where: n.user_id == ^user_id
    end

    def sort_by_viewed_at(query) do
        from n in query,
        order_by: [desc: n.viewed_at]
    end

   def sort_by_created_at(query, direction \\ :asc) do
      if direction == :asc do
        from n in query,
           order_by: [asc: n.inserted_at]
      else
        from n in query,
           order_by: [desc: n.inserted_at]
      end
   end


    def select_by_channel(query, channel) do
       [username, tag] = String.split(channel, ".")
       user = User.find_by_username(username)
       if user == nil do
         user_id = -1
       else
         user_id = user.id
       end
       if Enum.member?(["all", "public"], tag) do
          from n in query,
            where: n.user_id == ^user_id
        else
          from n in query,
            where: n.user_id == ^user_id and ^tag in n.tags
        end
    end

   def select_by_user_and_tag(query, user, tag) do
       if Enum.member?(["all", "public"], tag) do
         from n in query,
           where: n.user_id == ^user.id
       else
         from n in query,
           where: n.user_id == ^user.id and ^tag in n.tags
       end
    end

    def select_by_viewed_at_hours_ago(query, hours_ago) do
        then = Timex.shift(Timex.now, [hours: -hours_ago])
        from n in query,
        where: n.channel == n.viewed_at >= ^then
    end

    def select_public(query, public) do
      if public == true do
        from n in query,
           where: n.public == ^true
      else
        query
      end
    end

    def select_by_tag(query, tag_list, condition \\ true) do
      if !is_list(tag_list) do
        tag_list = [tag_list]  # THIS IS BAD CODE -- TRACK THINS DOWN AND FIX
      end
      if condition do
        from n in query,
          where: ilike(n.tag_string, ^"%#{hd(tag_list)}%")
       else
         query
       end
    end


   def select_by_term(query, term, condition \\ true) do
      if condition do
        from n in query,
          where: ilike(n.title, ^"%#{term}%") or ilike(n.tag_string, ^"%#{term}%")
       else
         query
       end
    end

   def full_text_search(query, term, condition \\ false) do
      if condition do
        from n in query,
          where: ilike(n.content, ^"%#{term}%")
       else
         query
       end
    end

    def most_recent(items, n) do
      Enum.slice(items, 0..(n-1))
    end


end