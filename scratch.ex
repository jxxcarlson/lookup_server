case mode do
         "all" -> query2 = from note in query,
            where: ilike(note.tag_string, ^"%#{channel_name}%")
         "none" -> query2 = query
         "public" -> query2 = query # from note in query, where: note.public == true
         "nonpublic" -> query2 = from note in query, where: note.public == false
         _ -> query2 = from note in query, where: ilike(note.tag_string, ^"%#{tag}%")
       end