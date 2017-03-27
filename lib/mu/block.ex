defmodule MU.Block do

  def transform(text) do
    text = String.replace(text, "\r\n", "\n")
    # Regex.scan(~r/(*ANYCRLF)^\[([a-z].*)\].--.(.*).--/msU, text)
    Regex.scan(~r/^\[([a-z].*)\].^--.(.*).^--/msU, text)
    |> Enum.reduce(text, fn(triple, text) ->
       [target, block_type, block_contents] = triple;
       transform_block(String.to_atom(block_type), target, block_contents, text) end)
  end

  defp transform_block(:quote, target, block_contents, text) do
    replacement = "<div class='quote'>\n#{block_contents}\n</div>"
    String.replace(text, target,replacement  )
  end

  defp transform_block(:display, target, block_contents, text) do
    replacement = "<div class='display'>\n#{block_contents}\n</div>"
    String.replace(text, target,replacement  )
  end


    def formatCode(text) do
      out = Regex.replace(~r/\[code\][\r\n]--[\r\n](.*)[\r\n]--[\r\n]/msU, text, "<pre><code>\\n#\\1\\n</code></pre>")
      # IO.puts "OUTPUT OF FORMAT CODE: #{out}"
      # out
    end

  def formatVerbatim(text) do
        Regex.replace(~r/----(?:\r\n|[\r\n])(.*)(?:\r\n|[\r\n])----/msr, text, "<pre style='margin-bottom:-1.2em;;'>\\1</pre>")
  end

end
