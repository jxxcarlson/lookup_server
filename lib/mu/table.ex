defmodule MU.Table do

    defp process_table_row(row) do
      html_row = String.split(row, "|")
      |> Enum.map(fn(item) -> String.trim(item) end)
      |> Enum.filter(fn(item) -> item != "" end)
      |> Enum.map(fn(item) -> "<td>" <> item <> "</td>"end )
      "<tr>#{html_row}</tr>"
    end

    defp process_table(table_contents) do
      rows = String.split(table_contents, "\n")
      |> Enum.filter(fn(row) -> row != "" end)
      |> Enum.map(fn(row) -> process_table_row(row) end)
      |> Enum.join("\n")
      "<div  style=\"whitespace:normal; margin-left:2em;\"><table style=\"width:80%; align:center\">\n#{rows}\n</table>\</div>"
    end

    def format(text) do
      sc = Regex.scan(~r/^\|===.(.*).\|===/msr, text)
      sc |> Enum.reduce(text, fn(item, text) -> [a,b] = item; String.replace(text, a, process_table(b)) end)
    end

end