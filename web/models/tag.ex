defmodule LookupPhoenix.Tag do
    import LookupPhoenix.Note
    alias LookupPhoenix.Note

    # A tag is string that starts with :, eg. :foo
    # get_tags(text) reeturns a list of the tags found in
    # the string tsxt
    def get_tags(text) do
      Regex.scan(~r/(:[a-zA-Z]\S*)\s/, text)
      |> Enum.map(fn(x) -> hd x end)
    end

    #def get_tags_from_note(note: Note) do
    #  get_tags(note.text)
    #end

    # def get_tags_from_note_list(noteList: xxx)


end