defmodule MU.Section do

   alias LookupPhoenix.Utility

    defp formatSectionHeading(triple, text) do
      [target, prefix, item] = triple
       identifier = "_" <> Utility.str2identifier(item)
       level = String.length(prefix)
       heading = "h#{level}"
       String.replace(text, target, "<#{heading}><a name=\"#{identifier}\">#{item}</a></#{heading}>\n")
    end

    defp index_item(triple) do
      [_, _, item] = triple
      identifier = "#_" <> Utility.str2identifier(item)
      "<p class=\"note_index_item\"><a href='#{identifier}'>#{item}</a><p>\n"
    end

    defp make_index(text, triples) do
      cond do
        length(triples) < 2 ->
          text
        true ->
          index_text = Enum.reduce(triples, "", fn(triple, acc) -> acc <> index_item(triple) end)
          "<div class=\"note_index\">\n<strong>Contents</strong>\n" <> index_text <> "</div>\n" <> text
      end
    end

    # A triple has the form [target, prefix, item]
    def format(text) do
      triples = Regex.scan(~r/^(=*) (.*)$/mU, text)
      Utility.report("triples", triples)
      triples |> Enum.reduce(text, fn(triple, text) -> formatSectionHeading(triple, text) end)
      |> make_index(triples)
    end


end