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
       [type | args]= String.split(block_meta, ",") |> Enum.map(fn(item) -> String.trim(item) end)
       type_parts = String.split(type, ".")
       if length(type_parts) > 1 do
         [type | block_species ] = type_parts
         species = hd(block_species)
       else
         species = nil
       end
       params = %{species: species, target: target, text: text, args: args, contents: block_contents}
       transform_block(String.to_atom(type), params) end)
  end

  defp transform_block(:quote, params) do
    cond do
      params.args == [] ->
        replacement = "<div class='quote'>\n#{params.contents}\n</div>"
      true ->
        attribution = hd params.args
        replacement = "<div class='quote'>\n#{params.contents}\n\n-- #{attribution}</div>"
    end
    String.replace(params.text, params.target,replacement)
  end

  defp transform_block(:display, params) do
    cond do
      params.args == [] ->
        replacement = "<div class='display'>\n#{params.contents}</div>"
      true ->
        title = hd params.args
        replacement = "<div class='display'><strong>#{title}</strong>\n#{params.contents}</div>"
    end
    String.replace(params.text, params.target,replacement)
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end


  defp transform_block(:click, params) do
    identifier = random_string(4)
    cond do
      params.args == [] ->
         replacement = "<span><span id=\"QQ.#{identifier}\" class=\"answer_head\">Answer:</span> <span id=\"QQ.#{identifier}.A\" class=\"hide_answer\">#{params.contents}</span></span>"
      true ->
         title = hd params.args
         replacement = "<span><span id=\"QQ.#{identifier}\" class=\"answer_head\">#{title}</span> <span id=\"QQ.#{identifier}.A\" class=\"hide_answer\">#{params.contents}</span></span>"
    end
    String.replace(params.text, params.target,replacement)
  end

  defp transform_block(:env, params) do
    cond do
      params.species == nil ->
        replacement = "<div class='env'>\n#{params.contents}</div>"
      true ->
        replacement = """
    <div class="env"><strong>#{String.capitalize(params.species)}.</strong>
      <div class="env_body">
        #{params.contents}
      </div>
    </div>
    """

    end
    String.replace(params.text, params.target,replacement)
  end

  def formatCode(text) do
    out = Regex.replace(~r/\[code\][\r\n]--[\r\n](.*)[\r\n]--[\r\n]/msU, text, "<pre><code>\\n#\\1\\n</code></pre>")
    # IO.puts "OUTPUT OF FORMAT CODE: #{out}"
    # out
  end

  def formatVerbatim(text) do
        Regex.replace(~r/----(?:\r\n|[\r\n])(.*)(?:\r\n|[\r\n])----/msr, text, "<pre>\\1</pre>")
  end



end
