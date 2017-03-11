    new_params = %{"content" => new_content, "title" => new_title,
      "edited_at" => Timex.now, "tag_string" => note_params["tag_string"],
      "tags" => tags, "public" => note_params["public"],
      "shared" => note_params["shared"], "tokens" => note_params["tokens"],
      "idx" => note_params["idx"], "identifier" => note_params["identifier"]}
