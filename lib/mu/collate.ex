defmodule MU.Collate do

   def collate(input_text, options) do
     cond do
       options.public == true ->
         prepare_for_collation(input_text, options)
                 |> Enum.reduce("", fn(id, acc) -> collate_one_public(id, acc) end)
       options.public == false ->
         prepare_for_collation(input_text, options)
          |> Enum.reduce("", fn(id, acc) -> collate_one(id, acc) end)
       true ->
          input_text
     end
   end


  defp prepare_item(item, prefix) do
       cond do
         is_integer(item) -> Repo.get!(Note, item).identifier
         Regex.match?(~r/^[1-9].[0-9]*/, item) -> Repo.get!(Note, String.to_integer(item)).identifier
         true -> "#{prefix}.#{item}"
       end
   end

   defp prepare_for_collation(text, options) do
     # split input into lines
     [user_info|data] = String.split(String.trim(text), ["\n", "\r", "\r\n"])
     # remove empty items
     |> Enum.filter(fn(item) -> item != "" end)
     # remove comments:
     |> Enum.map(fn(item) -> Regex.replace(~r/(.*)\s*\#.*$/U, item, "\\1") end)
     [_, username] = String.split(user_info, "=")

     data |> Enum.map(fn(item) -> prepare_item(item, username) end)
     |> Enum.filter(fn(item) -> Regex.match?(~r/^#{username}\./, item) end)
   end

   defp collate_one(id, str) do
     note = Note.get(id)
     str <> "\n\n" <> "== " <> note.title <> "\n\n" <> note.content <> "\n\n"
   end

   defp collate_one_public(id, str) do
     note = Note.get(id)
     if note.public == true do
       str <> "\n\n" <> "== " <> note.title <> "\n\n" <> note.content <> "\n\n"
     else
       str
     end
   end

end