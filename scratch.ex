[debug] QUERY OK source="users" db=0.3ms
SELECT u0."id", u0."name", u0."username", u0."email", u0."password", u0."password_hash", u0."registration_code", u0."tags", u0."read_only", u0."admin", u0."number_of_searches", u0."search_filter", u0."inserted_at", u0."updated_at" FROM "users" AS u0 WHERE (u0."id" = $1) [9]
[debug] Processing by LookupPhoenix.NoteController.update/2
  Parameters: %{"_csrf_token" => "GlwKCwkBChJkF3xnBSBWMVI0H35XNgAA/nX8HlxG/S7QWxcAjLNQ9w==", "_method" => "put", "_utf8" => "✓", "id" => "302", "note" => %{"content" => " <a href=\"http://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html\" target=\"_blank\">elixir-lang.org</a>  ", "id_list" => "", "index" => "", "tag_string" => "", "title" => "Elixir supervisors"}}
  Pipelines: [:browser]