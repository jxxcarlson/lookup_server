  defp make_link(item) do
    [id, id2] = item
    title = Note.get(id).title
    "<a href=\"/note2/#{id}/#{id2}/#{id}>#{id2}\">#{title}</a>"
  end

  # Example of toc_history argument:
  # [[904, 443], [903, 757], [905, 447]]
  def make_history_links(toc_history) do
     Enum.map(toc_history, fn(item) -> make_link(item) end)
     |> Enum.join(" >  ")
  end