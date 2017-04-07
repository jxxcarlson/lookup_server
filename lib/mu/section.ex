defmodule MU.Section do

   alias LookupPhoenix.Utility

    def formatSectionHeading(triple, text) do
      [target, prefix, item] = triple
       identifier = "_" <> Utility.str2identifier(item)
       level = String.length(prefix)
       heading = "h#{level}"
       String.replace(text, target, "<#{heading} name=\"#{identifier}\">#{item}</#{heading}>\n")
    end

    def formatSectionHeadings(text) do
      Regex.scan(~r/^(=*) (.*)$/mU, text)
      |> Enum.reduce(text, fn(triple, text) -> formatSectionHeading(triple, text) end)
    end


end