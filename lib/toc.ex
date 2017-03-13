defmodule LookupPhoenix.TOC do

  alias LookupPhoenix.Utility
  alias LookupPhoenix.Note
  alias LookupPhoenix.Constant

  defp is_in_toc_history1(toc_history, note, note2) do
    Enum.member?(toc_history, [note.id, note2.id])
  end

  defp is_in_toc_history(toc_history, note, note2) do
    toc_history
    |> Enum.map(fn(item) -> hd(item) end)
    |> Enum.member?(note.id)
  end

  defp normalize_id(id) do
    cond do
      is_integer(id) -> id
      true -> Note.get(id).id
    end
  end

  defp normalize_item(item) do
    [id, id2] = item
    [normalize_id(id), normalize_id(id2)]
  end

  defp normalize(toc_history) do
    Enum.map(toc_history, fn(item) -> normalize_item(item) end)
  end

  def update_toc_history(toc_history_string, note, note2) do
      toc_history = String.split(toc_history_string, ";")
      |> Enum.map(fn(item) -> String.split(item, ">") end)
      |> normalize

      cond do
        Enum.member?(note2.tags, ":toc") && !is_in_toc_history(toc_history, note, note2) ->
          IO.puts "BRANCH A"
          toc_history = toc_history ++ [[note.id, note2.id]]
        Enum.member?(note2.tags, ":toc") && !is_in_toc_history(toc_history,  note, note2) ->
          IO.puts "BRANCH B"
          toc_history = toc_history ++ [[note2.id, 100]]
        true -> toc_history
      end

  end

  defp ths1(elem) do
    [id, id2] = elem
     "#{id}>#{id2}"
  end

  defp historify(list) do
    n = length(list) - 1
    Enum.reduce(0..n, [], fn(k, acc) -> acc ++ [Enum.slice(list, 0..k)] end)
  end

  def make_history_string(toc_history) do
     Enum.reduce(toc_history, [], fn(elem, acc) -> acc ++ [ths1(elem)] end)
     |> Enum.join(";")
  end

  def make_history(toc_history) do
    Enum.reduce(toc_history, [], fn(elem, acc) -> acc ++ [elem] end)
  end

  defp make_link(toc_history) do
    n = length(toc_history) - 1
    [id, id2] = Enum.at(toc_history, n)
    title = Note.get(id).title
    history = make_history_string(toc_history)
    "<a href=\"/show2/#{id}/#{id2}/#{history}\">#{title}</a>"
  end

  # Example of toc_history argument:
  # [[904, 443], [903, 757], [905, 447]]
  def make_history_links(toc_history) do
    toc_history2 = historify(toc_history)
    Enum.map(toc_history2, fn(th) -> make_link(th) end)
    |> Enum.join(" >  ")
  end

  defp lines_from_note_content(text) do
    text
    |> String.trim
    # split input into lines
    |> String.split(["\n", "\r", "\r\n"])
    # remove comments:
    |> Enum.map(fn(item) -> Regex.replace(~r/(.*)\s*\#.*$/U, item, "\\1") end)
    # remove empty items
    |> Enum.filter(fn(item) -> item != "" end)
  end

  defp first_id (text) do
    item = lines_from_note_content(text)
    |> Enum.filter(fn(line) -> !Regex.match?(~r/^title/, line) end)
    |> hd
    |> String.split(",")
    [id, _] = item
    id
  end

  defp prepare_toc(text, options) do
    text
    # split text into lines and normalize them
    |> lines_from_note_content
       # Make TOC items
    |> Enum.map(fn(line) -> make_toc_item(line, options) end)
  end


  defp make_toc_item(line, options) do
      toc_history = options.toc_history
      IO.puts "IN RENDER TEXT, toc_history: #{toc_history}"
      IO.puts "IN RENDER TEXT, line #{line}"
      [id, label] = String.split(line, ",")
      IO.puts "id = #{id}, label = #{label}"
      cond do
        id == "title" ->
          "<p class=\"title\">#{label}</p>"
        true ->
          note = Note.get(id)
          IO.puts "IN make_toc_item, note id = #{note.id}"
          IO.puts "IN make_toc_item, toc_history = #{toc_history}"
          if Enum.member?(note.tags, ":toc") && !String.contains?(toc_history, to_string(note.id)) do
            toc_history = toc_history <> ";" <> to_string(note.id) <> ">" <>  first_id(note.content)
          end
          "<p><a href=\"#{Constant.home_site}/show2/#{options.note_id}/#{id}/#{toc_history}\">#{label}</a></p>"
      end
  end

  def history2nav(history_string) do

  end

  def process(text, options) do
    prepare_toc(text, options)
    |> Enum.reduce("", fn(item, acc) -> acc <> item end)
  end


end