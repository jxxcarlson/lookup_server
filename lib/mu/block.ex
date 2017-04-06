defmodule MU.Block do


  @moduledoc """
  Module MU.Block parses and renders blocks.  There is a
  single public function, MU.block.transform(TEXT) -> TEXT


  Block Example:

  [quote, Oscar Wilde]
  --
  There are only two tragedies in life: one is not getting
  what one wants, and the other is getting it.
  --

  Format:

  [BLOCK_PARAMS]
  --
  BLOCK_BODY
  --

  BLOCK_PARAMS = items separated by commas
  The first item is the block type, e.g., "quote", "click"
  The remaining items (if any) are the block args.  Often the
  second arg is a title.

"""
  def transform(text) do
    text = String.replace(text, "\r\n", "\n")
    # Regex.scan(~r/(*ANYCRLF)^\[([a-z].*)\].--.(.*).--/msU, text)
    Regex.scan(~r/^\[([a-z].*)\].^--.(.*).^--/msU, text)
    |> Enum.reduce(text, fn(triple, text) ->
       [target, block_meta, block_contents] = triple;
       [block_type|block_args]= String.split(block_meta, ",") |> Enum.map(fn(item) -> String.trim(item) end)
       transform_block(String.to_atom(block_type), target, text, block_args, block_contents) end)
  end

  defp transform_block(:quote, target, text, block_args, block_contents) do
    cond do
      block_args == [] ->
        replacement = "<div class='quote'>\n#{block_contents}\n</div>"
      true ->
        attribution = hd block_args
        replacement = "<div class='quote'>\n#{block_contents}\n\n-- #{attribution}</div>"
    end
    String.replace(text, target,replacement)
  end

  defp transform_block(:display, target,  text, block_args, block_contents) do
    cond do
      block_args == [] ->
        replacement = "<div class='display'>\n#{block_contents}</div>"
      true ->
        title = hd block_args
        replacement = "<div class='display'><strong>#{title}</strong>\n#{block_contents}</div>"
    end
    String.replace(text, target,replacement)
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end


  defp transform_block(:click, target,  text, block_args, block_contents) do
    identifier = random_string(4)
    cond do
      block_args == [] ->
         replacement = "<span><span id=\"QQ.#{identifier}\" class=\"answer_head\">Answer:</span> <span id=\"QQ.#{identifier}.A\" class=\"hide_answer\">#{block_contents}</span></span>"
      true ->
         title = hd block_args
         replacement = "<span><span id=\"QQ.#{identifier}\" class=\"answer_head\">#{title}</span> <span id=\"QQ.#{identifier}.A\" class=\"hide_answer\">#{block_contents}</span></span>"
    end
    String.replace(text, target,replacement)
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
