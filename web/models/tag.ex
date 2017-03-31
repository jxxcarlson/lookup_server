defmodule LookupPhoenix.Tag do
    import LookupPhoenix.Note

    alias LookupPhoenix.Note
    alias LookupPhoenix.Repo
    alias LookupPhoenix.Tag
    alias LookupPhoenix.Search
    alias LookupPhoenix.Utility


    def str2tags(str) do
      str |> String.split(",") |> Enum.map(fn(str) -> String.trim(str) end)
    end

    defp insert_element(element, list) do
        if Enum.member?(list, element) do
          list
        else
          [element] ++ list
        end
    end

    # merge elements of element_list into list
    defp merge_elements_into_list(element_list, list) do
      Enum.reduce(element_list, list, fn(element, list) -> insert_element(element, list) end)
    end

    # merge tags from note into list
    defp merge_tags_from_note(note, list) do
      note.tags
      |> merge_elements_into_list(list)
    end

    # scope = :all | :public
    def get_all_user_tags(scope, user) do
      Note
      |> NoteSearch.for_user(user.id)
      |> NoteSearch.select_public(scope == :public)
      |> Repo.all
      |> Enum.reduce([], fn(note, list) -> merge_tags_from_note(note, list) end)
    end

    def pretty(tag) do
      "#{tag["name"]}, #{tag["freq"]}"
    end


    #############

    # alias LookupPhoenix.Note; alias LookupPhoenix.User; alias LookupPhoenix.Tag; alias LookupPhoenix.Repo
    #  alias LookupPhoenix.Utility; u = User |> Repo.get!(9);  ff = Tag.tag_frequencies(u,"all")

    defp update_frequencies_for_tag(tag, freqs) do
      value = freqs[tag]
      if value == nil do
        freqs
      else
        new_freq = freqs[tag] + 1
        Map.merge(freqs, %{tag => new_freq})
      end
    end

    defp update_frequencies_for_note(note, freqs) do
       note.tags |> Enum.reduce(freqs, fn(tag, acc) -> update_frequencies_for_tag(tag, acc) end)
    end

    defp update_frequencies_for_user(freqs, scope, user) do
    Note
      |> NoteSearch.for_user(user.id)
      |> NoteSearch.select_public(scope == :public)
      |> Repo.all
      |> Enum.reduce(freqs, fn(note, freqs) -> update_frequencies_for_note(note, freqs) end)
    end

    # scope = :all|:public
    defp tag_frequencies(scope, user) do
      get_all_user_tags(scope, user)
      |> Enum.filter(fn(tag) -> tag != "" end)
      |> Enum.reduce(%{}, fn(tag, acc) -> Map.merge(acc, %{tag => 0}) end)
      |> update_frequencies_for_user(scope, user)
      |> Utility.map22list
      |> Utility.sort2list("desc")
    end

    # scope = :all|:public
    def tags_by_frequency(scope, user) do
      tag_frequencies(scope, user) |> Enum.map( fn(pair) -> %{name: hd(pair), freq: hd(tl(pair))} end)
    end

end