defmodule LookupPhoenix.Tag do
    import LookupPhoenix.Note

    alias LookupPhoenix.Note
    alias LookupPhoenix.Repo

    # A tag is string th    at starts wit               h :, eg. :foo
    # get_tags(text) reeturns a list of the tags found in
    # the string tsxt
    def get_tags(text) do
      Regex.scan(~r/(\s:[a-zA-Z]\S*)/, " "<>text<>" ")
      |> Enum.map(fn(x) -> String.trim(hd(x)) end)
    end

    def get_tags_from_note(note) do
      get_tags(note.content)
    end

    def insert_element(element, list) do
        if Enum.member?(list, element) do
          list
        else
          [element] ++ list
        end
    end

    # merge elements of element_list into list
    def merge_elements_into_list(element_list, list) do
      Enum.reduce(element_list, list, fn(element, list) -> insert_element(element, list) end)
    end

    # merge tags from note into list
    def merge_tags_from_note(note, list) do
      get_tags_from_note(note)
      |> merge_elements_into_list(list)
    end

    def get_all_tags do
      Note
      |> Repo.all
      |> Enum.reduce([], fn(note, list) -> merge_tags_from_note(note, list) end)
    end

    def get_all_user_tags(user_id) do
      Note.notes_for_user(user_id)
      |> Enum.reduce([], fn(note, list) -> merge_tags_from_note(note, list) end)
    end

    def pretty(tag) do
      String.replace(tag, ":", "")
    end


    ##############

    def put_element(element, map) do
      if map[element] == nil do
        Map.merge(map , %{element =>1})
      else
        %{map | element => map[element] + 1}
      end
    end

    def merge_elements_into_map(element_list, map) do
       Enum.reduce(element_list, map, fn(element, map) -> put_element(element, map) end)
    end

    def merge_tags_from_note_to_map(note, map) do
        get_tags_from_note(note)
        |> merge_elements_into_map(map)
    end

    def merge_all_user_tags_into_map(user_id) do
        Note.notes_for_user(user_id)
        |> Enum.reduce(%{}, fn(note, map) -> merge_tags_from_note_to_map(note, map) end)
    end


end