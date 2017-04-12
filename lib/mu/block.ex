defmodule MU.Block do

  import MU.Regex
  alias LookupPhoenix.Utility


  def split_at(str, sep_str) do
    if str == nil do
      [nil, nil]
    else
      result = String.split(str, sep_str)
      if length(result) == 1 do
        [hd(result), nil]
      else
        result
      end
    end
  end


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
    # text = String.trim(text)
    text = String.replace(text, "\r\n", "\n") # normalizze
    Regex.scan(block_regex, text)
    |> Enum.reduce(text, fn(triple, text) ->
    
       [target, block_meta, block_contents] = triple;
       [type | args]= split_at(block_meta, ",")
       [type, species] = split_at(type, ".")
       [species | label] = split_at(species, "#")

       if label != nil && label != [] do
         label = hd(label)
       else
         label = nil
       end

       params = %{type: type, species: species, label: label, target: target,
         text: text, args: args, contents: block_contents
         }
       # Utility.report("BLOCK PARAMS",  params)
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

  defp transform_block(:blurb, params) do
    replacement =  params.contents
    title = String.capitalize(params.type)
    replacement = params.contents
    replacement = "<div class='blurb'><span style=\"font-style:italic\">#{params.contents}</span></div>"
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
      params.species != nil ->
        transform_env_block(String.to_atom(params.species), params)
      true ->
        transform_open_env_block(params)
    end
  end

  defp transform_env_block(:equationalign, params) do
    replacement = "<div class='env'>\n\\[\n\\begin\{split\}\n#{params.contents}\n\\end\{split\}\n\\]\n</div>"
    """
     <div class="env">
           <div>
             #{params.contents}
           </div>
     </div>
    """
    String.replace(params.text, params.target, replacement)
  end

  @doc """
  A basic env.equation block looks like this

  [env.equation]
  --
  a^2 + b^2 = c^2
  --

  It is rendered as

  \[
  \begin{equation}
  a^2 + b^2 = c^2
  \end{equation}
  \]

  A variant of this block contains a label:
  [env.equation#pythag]
  --
  a^2 + b^2 = c^2
  --

  It is rendered as
  \[
  \begin{equation}
  \label{pythag}
  a^2 + b^2 = c^2
  \end{equation}
  \]

  """
  defp transform_env_block(:equation, params) do
    Utility.report("EQUATION BLOCK", %{label: params.label})
    if params.label == nil do
      replacement = "<div class='env'>\n\\[\n\\begin\{equation\}\n#{params.contents}\n\\end\{equation\}\n\\]\n</div>"
    else
      # replacement = "<div class='env'>\n\\[\n\\begin\{equation\}\n\\label\{#{params.label}\}\n#{params.contents}\n\\end\{equation\}\n\\]\n</div>"
      replacement = "<div class='env'>\n\\[\n\\begin\{equation\}\n#{params.contents}\n\\end\{equation\}\n\\]\n</div>"
    end
    """
     <div class="env">
           <div>
             #{params.contents}
           </div>
     </div>
    """
    String.replace(params.text, params.target, replacement)
  end

  @doc """
  A texmacro block looks like this

  [env.texmacro]
  --
  \newcommand{\bor}{\mathbf{r}}
  \newcommand{\bov}{\mathbf{v}}

  \newcommand{\boa}{\mathbf{a}}
  --

  It is rendered as
  \[
   \newcommand{\bor}{\mathbf{r}}
   \newcommand{\bov}{\mathbf{v}}
   \newcommand{\boa}{\mathbf{a}}
  \]

  Notice that blank lines are stripped out
  """
  defp transform_env_block(:texmacro, params) do

    contents = String.split(params.contents, ["\n", "\r", "\r\n"])
      |> Enum.filter(fn(line) -> line != "" end)
      |> Enum.join("\n")

    replacement = "<div class='env'>\n\\[\n#{contents}\n\\]\n</div>"
    """
     <div class="env">
           <div>
             #{params.contents}
           </div>
     </div>
    """
    String.replace(params.text, params.target, replacement)
  end

  defp transform_env_block(_, params) do
    replacement = """
    <div class="env"><strong>#{String.capitalize(params.species)}</strong>
      <div class="env_body">
        #{params.contents}
      </div>
    </div>
    """
    String.replace(params.text, params.target, replacement)
  end

  defp transform_open_env_block(params) do
    replacement = "<div class='env'>\n#{params.contents}</div>"
    String.replace(params.text, params.target, replacement)
  end


 # Default if the block type is not recognized
  defp transform_block(_, params) do
    replacement =  params.contents
    title = String.capitalize(params.type)
    replacement = "<div class='open_block'><strong>#{title}</strong>\n<p>#{params.contents}</p></div>"

    String.replace(params.text, params.target,replacement)
  end

  @doc """
  head_excerpt(text, N) return the
  first N words of text.
  """
  def head_excerpt(text, n_words) do
      text
      |> String.split(" ")
      |> Enum.slice(0..(n_words-1))
      |> Enum.join(" ")
  end

  @doc """
  A blurb looks like this

  [blurb]
  --
  This is an extremely cool article.
  Please read on!
  --

  A blurb is rendered in main text by
  Block.format(:blurb, text).  In the
  index, it is rendered by formatBlurb(text).
  If a blurb is present, it forms the entirety
  of the index entry.  If it is not present,
  the first N words are displayed (this is
  often ugly).
"""
  def formatBlurb(text) do
      triple = Regex.run(blurb_regex, text)
      if triple != nil do
        [_, _, block_contents] = triple;
        block_contents
      else
        head_excerpt(text, 7)
      end
    end

  def formatCode(text) do
    out = Regex.replace(~r/\[code\][\r\n]--[\r\n](.*)[\r\n]--[\r\n]/msU, text, "<pre><code>\\n#\\1\\n</code></pre>")
  end

  def formatVerbatim(text) do
        Regex.replace(~r/----(?:\r\n|[\r\n])(.*)(?:\r\n|[\r\n])----/msr, text, "<pre>\\1</pre>")
  end



end
