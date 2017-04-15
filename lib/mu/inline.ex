defmodule MU.Inline do

   alias LookupPhoenix.Utility

   def transform(text) do
     # begin_time = Timex.now
     result = text
      |> formatInlineCode
      |> formatBold
      |> formatItalic
      |> formatMDash
      |> formatNDash
      |> formatRed
      |> highlight
      # Utility.benchmark(begin_time, text, "1. MU.Inline")
      result
   end

   def formatNDash(text) do
      # \s(--)\s
      Regex.replace(~r/\s(--) /, text, " &ndash; ")
    end

    def formatMDash(text) do
       Regex.replace(~r/\s(---) /, text, " &mdash; ")
    end

    def formatStrike(text) do
       Regex.replace(~r/~~(.*)~~/U, text, "<span style='text-decoration: line-through;color:darkred'>\\1</span>")
    end

   def formatInlineCode(text) do
      Regex.replace(~r/\`(.*)\`/U, text, "<tt style='color:darkred; font-weight:400'>\\1</tt>")
    end

    def formatBold(text) do
       Regex.replace(~r/(\*(.*)\*)/U, text, "<strong>\\2</strong>")
    end

    def formatItalic(text) do
       Regex.replace(~r/(\s)_(.*)_(\s)/U, text, "\\1<i>\\2</i>\\3")
    end

    def formatRed(text) do
       Regex.replace(~r/red:\[(.*)\]/U, text, "<span style='color:darkred;'>\\1</span>")
    end

   def highlight(text) do
     Regex.replace(~r/#(\S.*)#/U, text, "<span style='color:darkred;'>\\1</span>")
   end

end