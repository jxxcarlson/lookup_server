defmodule LookupPhoenix.Block do

  alias LookupPhoenix.Block
  alias LookupPhoenix.Utility

  def transform(text) do
    text = String.replace(text, "\r\n", "\n")
    IO.puts "QUOTE: Enter (abcdef)"
    Utility.report("scan result", Regex.scan(~r/^\[([a-z].*)\].--.(.*).--/msU, text))
    Regex.scan(~r/(*ANYCRLF)^\[([a-z].*)\].--.(.*).--/msU, text)
    |> Enum.reduce(text, fn(triple, text) ->
       [target, block_type, block_contents] = triple;
       transform_block(String.to_atom(block_type), target, block_contents, text) end)
  end

  defp transform_block(:quote, target, block_contents, text) do
    replacement = "<div class='quote'>\n#{block_contents}\n</div>"
    String.replace(text, target,replacement  )
  end

end
