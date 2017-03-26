defmodule LookupPhoenix.Tag do
    import LookupPhoenix.Note

    alias LookupPhoenix.Note
    alias LookupPhoenix.Repo
    alias LookupPhoenix.Tag
    alias LookupPhoenix.Search
    alias LookupPhoenix.Utility

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

    def initialize_tags(user) do
      params = %{"tags" => [], "public_tags" => []}
      changeset = changeset(user, params)
      Repo.update(changeset)
    end

    def initialize_user_tag_fields do
      User |> Repo.all |> Enum.map(fn(user) -> initialize_tags(user) end)
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

    # scope = :all | :public
    def get_all_user_tags(scope, user) do
      IO.puts "GET TAGS HERE!"
      notes = Search.all_notes_for_user(scope, :created_at, :asc, user)
      IO.puts "Notes found: #{length(notes)}"
      notes |> Enum.reduce([], fn(note, list) -> merge_tags_from_note(note, list) end)
      # |> Enum.filter(fn(x) -> !ignorable_tag(x) end)
    end

    def get_all_public_user_tags(user) do
      IO.puts "GET TAGS HERE!"
      notes = Search.all_notes_for_user(:public,  :created_at, :asc, user)
      IO.puts "Notes found: #{length(notes)}"
      notes |> Enum.reduce([], fn(note, list) -> merge_tags_from_note(note, list) end)
      # |> Enum.filter(fn(x) -> !ignorable_tag(x) end)
    end

    def pretty(tag) do
      "#{tag["name"]}, #{tag["freq"]}"
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
        Search.notes_for_user(user, %{"tag" => "all", "sort_by" => "created_at", "direction" => "desc"}).notes
        |> Enum.reduce(%{}, fn(note, map) -> merge_tags_from_note_to_map(note, map) end)
    end

    #############

    # alias LookupPhoenix.Note; alias LookupPhoenix.User; alias LookupPhoenix.Tag; alias LookupPhoenix.Repo
    #  alias LookupPhoenix.Utility; u = User |> Repo.get!(9);  ff = Tag.tag_frequencies(u,"all")

    def update_frequencies_for_tag(tag, freqs) do
      value = freqs[tag]
      if value == nil do
        freqs
      else
        new_freq = freqs[tag] + 1
        Map.merge(freqs, %{tag => new_freq})
      end
    end

    def update_frequencies_for_note(note, freqs) do
       note.tags |> Enum.reduce(freqs, fn(tag, acc) -> update_frequencies_for_tag(tag, acc) end)
    end

    def update_frequencies_for_user(freqs, user) do
      Search.all_notes_for_user(:all,  :created_at, :asc, user)
      |> Enum.reduce(freqs, fn(note, freqs) -> update_frequencies_for_note(note, freqs) end)
    end

    # scope = :all|:public
    def tag_frequencies(scope, user) do
      tags_to_process = Tag.get_all_user_tags(scope, user)

      IO.puts "TAGS TO PROCESS: #{length(tags_to_process)}"

      tags_to_process |> Enum.filter(fn(tag) -> tag != "" end)
      |> Enum.reduce(%{}, fn(tag, acc) -> Map.merge(acc, %{tag => 0}) end)
      |> update_frequencies_for_user(user)
      |> Utility.map22list
      |> Utility.sort2list("desc")
    end

    # scope = :all|:public
    def tags_by_frequency(scope, user) do
      # tag_frequencies(user, scope) |> Utility.proj1_2list
      tag_frequencies(scope, user) |> Enum.map( fn(pair) -> %{name: hd(pair), freq: hd(tl(pair))} end)
    end



end