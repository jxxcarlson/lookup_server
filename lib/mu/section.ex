defmodule MU.Section do

    def formatHeading1(text) do
      Regex.replace(~r/^== (.*)$/mU, text, "<h1>\\1</h1>\n")
    end

    def formatHeading2(text) do
       Regex.replace(~r/^=== (.*)$/mU, text, "<h2>\\1</h2>\n")
    end

   def formatHeading3(text) do
       Regex.replace(~r/^==== (.*)$/mU, text, "<h3>\\1</h3>\n")
   end

   def formatHeading4(text) do
          Regex.replace(~r/^==== (.*)$/mU, text, "<h4>\\1</h4>\n")
   end

end