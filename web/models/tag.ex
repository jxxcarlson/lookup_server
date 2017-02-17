defmodule LookupPhoenix.Tag do
    import LookupPhoenix.Note

    alias LookupPhoenix.Note
    alias LookupPhoenix.Repo
    alias LookupPhoenix.Tag
    alias LookupPhoenix.Search

    # A tag is string that starts with :, eg. :foo
    # get_tags(text) returns a list of the tags found in
    # the string tsxt
    def get_tags(text) do
      text2 = Regex.replace(~r/[`,.;]/, text,  "")
      Regex.scan(~r/(\s:[a-zA-Z]\S*)/, " "<>text2<>" ")
      |> Enum.map(fn(x) -> String.trim(hd(x)) end)
    end

    def get_tags_from_note(note) do
      get_tags(note.content)
    end

    ####

    def content2taglist(note) do
      get_tags_from_note(note)
    end

    def fixTags(note) do
      tag_list = content2taglist(note)

      tag_string = tag_list
      |> Enum.map( fn(tag) -> String.replace(tag, ":", "") end)
      |>  Enum.join(", ")

      content = RenderText.erase_words(note.content<> " ", tag_list)

      tag_list = tag_list |> Enum.map( fn(tag) -> String.replace(tag, ":", "") end)

      changeset = Note.changeset(note, %{"tags" => tag_list, "tag_string" => tag_string, "content" => content})
      Repo.update(changeset)
    end

    def fix_all_tags do
      Note |> Repo.all |> Enum.map(fn(note) -> fixTags(note) end)
    end

    def str2tags(str) do
      str |> String.split(",") |> Enum.map(fn(str) -> String.trim(str) end)
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
      note.tags
      |> merge_elements_into_list(list)
    end

    def get_all_tags do
      Note
      |> Repo.all
      |> Enum.reduce([], fn(note, list) -> merge_tags_from_note(note, list) end)
    end

    def ignorable_tag(tag) do
      [":gt", ":lt", ":eq"]
      |> Enum.member?(tag)
    end

    def get_all_user_tags(user) do
      IO.puts "GET TAGS HERE!"
      notes = Search.all_notes_for_user(user)
      IO.puts "Notes found: #{length(notes)}"
      notes |> Enum.reduce([], fn(note, list) -> merge_tags_from_note(note, list) end)
      # |> Enum.filter(fn(x) -> !ignorable_tag(x) end)
    end

    def get_all_public_user_tags(user) do
      IO.puts "GET TAGS HERE!"
      notes = Search.all_public_notes_for_user(user)
      IO.puts "Notes found: #{length(notes)}"
      notes |> Enum.reduce([], fn(note, list) -> merge_tags_from_note(note, list) end)
      # |> Enum.filter(fn(x) -> !ignorable_tag(x) end)
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

    def merge_all_user_tags_into_map(user) do
        Search.notes_for_user(user, %{"tag" => "all", "sort_by" => "created_at", "direction" => "desc"})
        |> Enum.reduce(%{}, fn(note, map) -> merge_tags_from_note_to_map(note, map) end)
    end


end