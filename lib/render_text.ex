defmodule RenderText do
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Note
  alias LookupPhoenix.Utility
  alias LookupPhoenix.Constant
  alias LookupPhoenix.Constant

############# PUBLIC ##################

    def transform(text, options \\ %{mode: "show", process: "none", collate: false}) do
      collate(text, options)
      processTOC(text, options)
      |> String.trim
      |> formatCode
      |> padString
      |> linkify(options)
      |> apply_markdown
      |> formatChem
      |> formatChemBlock
      |> insert_mathjax(options)
      |> String.trim
    end

    def preprocessURLs(text) do
      text
      |> padString
      # |> simplifyURLs
      # |> preprocessImageURLs
      |> String.trim
    end

    def firstParagraph(text) do
      short_text = Regex.run(~r/.*\s\s/, text)
      case short_text do
        nil -> text
        [] -> text
        _ -> (List.first short_text) <> " •••"
      end
    end

    def format_for_index(text) do
      text
      |> firstParagraph
      |> linkify(%{mode: "index", process: "node"})
      |> formatBold
      |> formatRed
      |> formatItalic
    end

    ############# PRIVATE ##################


    defp padString(text) do
      "\n" <> text <> "\n"
    end


    defp linkify(text, options) do
      text
      # |> simplifyURLs
      |> makeYouTubePlayer(options)
      |> makeAudioPlayer
      |> makeImageLinks(options)
      |> makeFormattedImageLinks(options)
      |> makeUserLinks
      |> makeSmartLinks
      |> makePDFLinks(options)
      |> siteLink
      |> String.trim
    end

    defp apply_markdown(text) do
      text
      |> padString
      |> formatCode
      |> formatVerbatim
      |> formatInlineCode
      |> padString
      |> formatBold
      |> formatItalic
      |> indexWord
      |> formatMDash
      |> formatNDash
      |> formatRed
      |> padString
      |> formatItems
      |> formatAnswer
      |> highlight
      |> formatXREF
      |> formatHeading1
      |> formatHeading2
      |> formatHeading3

      #|> formatStrike

    end

    defp getURLs(text) do
      Regex.scan(~r/((http|https):\/\/\S*)\s/, " " <> text <> " ", [:all])
      |> Enum.map(fn(x) -> hd(tl(x)) end)
    end

    def prepURLs(url_list) do
       Enum.map(url_list, fn(x) -> [x, hd(String.split(x, "?"))] end)
    end

    defp simplify_one_URL(substitution_item, text) do
      target = hd(substitution_item)
      replacement = hd(tl(substitution_item))
      String.replace(text, target, replacement)
    end

    defp simplifyURLs(text) do
      url_substitution_list = text |> getURLs |> prepURLs
      Enum.reduce(url_substitution_list, text, fn(substitution_item, text) -> simplify_one_URL(substitution_item, text) end)
    end

    defp preprocessImageURLs(text) do
      Regex.replace(~r/[^:]((http|https):\/\/\S*\.(jpg|jpeg|png|gif))\s/i, text, " image::\\1 ")
    end

    defp makeDumbLinks(text) do
      Regex.replace(~r/\s((http|https):\/\/[a-zA-Z0-9\.\-\/&=\?#!@_%]*)\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">LINK</a> ")
    end

    # ha ha http://foo.bar.io/a/b/c blah blah => 1: http://foo.bar.io/a/b/c, 3: foo.bar.io
    defp makeSmartLinks(text) do
       #Regex.replace(~r/\s((http|https):\/\/([a-zA-Z0-9\.\-_%-]*)([\/?=#]\S*|))\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
       Regex.replace(~r/\s((http|https):\/\/([a-zA-Z0-9\.\-_%-']*)([\/?=#]\S*|))\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
    end

    defp siteLink(text) do
      Regex.replace(~r/site:(.*)\[(.*)\]/U, text,  " <a href=\"#{LookupPhoenix.Constant.home_site}/site/\\1\" target=\"_blank\">\\2</a> ")
    end

    # http://foo.io/ladidah/mo/stuff => <a href="http://foo.io/ladida/foo.io"" target=\"_blank\">foo.io/ladidah</a>
    defp makeUserLinks(text) do
      Regex.replace(~r/\s((http|https):\/\/[a-zA-Z0-9\.\-\/&=~\?#!@_%-']*)\[(.*)\]\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
    end

    defp makeAudioPlayer(text) do

       Regex.replace(~r/(http|https):\/\/(.*(mp3|wav))/i, " "<>text<>" ", "<audio controls> <source src=\"\\0\" type=\"audio/\\3\" >Your browser does not support the audio element.</audio>")

    end

    defp makeImageLinks1(text, options) do
       case options[:mode] do
         "index" ->
           Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
         "show" ->
           Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" height=\"600px\" > ")
         #_ ->
         #  Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
       end

    end

    defp makeImageLinks(text, options) do
       case options[:mode] do
         "index" ->
           Regex.replace(~r/(http|https):\/\/(.*(png|jpg|jpeg|gif))(\s|$)/i, " "<>text<>" ", " <img src=\"\\0\" width=\"120px\" height=\"120px\" > ")
         "show" ->
           Regex.replace(~r/(http|https):\/\/(.*(png|jpg|jpeg|gif))(\s|$)/i, " "<>text<>" ", " <img src=\"\\0\" height=\"300px\" > ")
         #_ ->
         #  Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
       end

    end

    defp makeFormattedImageLinks(text, options) do
       case options[:mode] do
         "index" ->
           Regex.replace(~r/((http|https):\/\/(.*(png|jpg|jpeg|gif)))\[(.*)\]/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
         "show" ->
           Regex.replace(~r/((http|https):\/\/(.*(png|jpg|jpeg|gif)))\[(.*)\]/i, " "<>text<>" ", " <img src=\"\\1\" style=\"\\5\" > ")
         #_ ->
         #  Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
       end

    end

    defp makeYouTubePlayer(text, options) do
       case options[:mode] do
         "show" ->
           Regex.replace(~r/(https:\/\/youtu.be\/(.*))($|\s)/rU, " "<>text<>" ", "<iframe width=\"640\" height=\"360\" src=\"https://www.youtube.com/embed/\\2\"  frameborder=\"0\" allowfullscreen></iframe>")
         "index" ->
           Regex.replace(~r/(https:\/\/youtu.be\/(.*))($|\s)/rU, " "<>text<>" ", "<iframe width=\"213\" height=\"120\" src=\"https://www.youtube.com/embed/\\2\"  frameborder=\"0\" allowfullscreen></iframe>")
         #_ ->
         #  Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
       end

    end

    # (https://youtu.*)($|\s)

    defp formatHeading1(text) do
      Regex.replace(~r/^== (.*)$/mU, text, "<h1>\\1</h1>\n")
    end

    defp formatHeading2(text) do
       Regex.replace(~r/^=== (.*)$/mU, text, "<h2>\\1</h2>\n")
    end

   defp formatHeading3(text) do
       Regex.replace(~r/^==== (.*)$/mU, text, "<h3>\\1</h3>\n")
   end

   defp formatHeading4(text) do
          Regex.replace(~r/^==== (.*)$/mU, text, "<h4>\\1</h4>\n")
      end


    defp formatNDash(text) do
      # \s(--)\s
      Regex.replace(~r/\s(--) /, text, " &ndash; ")
    end

    defp formatMDash(text) do
       Regex.replace(~r/\s(---) /, text, " &mdash; ")
    end

    defp formatStrike(text) do
       # Regex.replace(~r/(^|\s)-([^-]*)-(\s)/U, text, " <span style='text-decoration: line-through'>\\2</span> \\3")
       Regex.replace(~r/(^|\s)-([^-\s]*)-(\s)/U, text, "\\1<span style='text-decoration: line-through;color:darkred'>\\2</span>\\3")
    end

    defp getItems(text) do
      Regex.scan(~r/^- (\S*.*)[\n\r]/msU, "\n" <> text)
      |> Enum.map(fn(x) -> hd(tl(x)) end)
      |> Enum.map(fn(item) -> String.trim(item) end)
    end


    defp formatItems(text) do
       getItems(text)
       |> Enum.reduce(text, fn(item, text) -> String.replace(text, "- " <> item, formatItem(item)) end)
    end

    defp formatItem  (item) do
      "<span style='margin-left:2em; text-indent:-0.7em;display:inline-block;margin-bottom:0.3em;'>-  #{item}</span>"
    end

    defp formatInlineCode(text) do
      Regex.replace(~r/\`(.*)\`/U, text, "<tt style='color:darkred; font-weight:400'>\\1</tt>")
    end

    defp formatVerbatim(text) do
      Regex.replace(~r/----(?:\r\n|[\r\n])(.*)(?:\r\n|[\r\n])----/msr, text, "<pre style='margin-bottom:-1.2em;;'>\\1</pre>")
    end

    # ``\n(.*)\n```

    defp formatBold(text) do
       Regex.replace(~r/(\*(.*)\*)/U, text, "<strong>\\2</strong>")
    end

    defp formatItalic(text) do
       Regex.replace(~r/(\s)_(.*)_(\s)/U, text, "\\1<i>\\2</i>\\3")
    end

    defp indexWord(text) do
      Regex.replace(~r/index:\[(.*)\]/U, text, "<span class=\"index_word\">\\1</span>")
    end

    defp formatRed(text) do
       Regex.replace(~r/red:\[(.*)\]/U, text, "<span style='color:darkred;'>\\1</span>")
    end

    defp formatChem(text) do
      Regex.replace(~r/chem:\[(.*)\]/U, text, "$\\ce{\\1}$")
    end

    defp formatChemBlock(text) do
      Regex.replace(~r/chem::\[(.*)\]/U, text, "$$\\ce{\\1}$$")
    end

    defp formatCode(text) do
      out = Regex.replace(~r/\[code\][\r\n]--[\r\n](.*)[\r\n]--[\r\n]/msU, text, "<pre><code>\\n#\\1\\n</code></pre>")
      IO.puts "OUTPUT OF FORMAT CODE: #{out}"
      out
    end

    defp formatAnswer(text) do
       Regex.replace(~r/answer:\[(.*)\]/U, text, "<p><span id=\"QQ\" class=\"answer_head\">Answer:</span> <span id=\"QQA\" class=\"hide_answer\">\\1</span></p>")
    end

    defp formatVerbatim(text) do
      Regex.replace(~r/verbatim:\[(.*)\]/U, text, "<pre>\\1</pre>")
    end

    defp scrubTags(text) do
      Regex.replace(~r/\s:.*\s/, " " <> text <> " ",    " ")
    end




    defp insert_mathjax!(text) do

        text <>  """

                  <script type="text/x-mathjax-config">
                    MathJax.Hub.Config( {tex2jax: {inlineMath: [['$','$']]}, TeX: { extensions: ["mhchem.js"] } });

                  </script>
                      <script type="text/javascript" async
                              src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_CHTML">
                   </script>

                   <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.9.0/styles/default.min.css">
                   <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.9.0/highlight.min.js"></script>
                   <script>hljs.initHighlightingOnLoad();</script>


"""

    end


    defp insert_mathjax(text, options) do
      if options[:process] == "latex" do
        text = insert_mathjax!(text)
      else
        text
      end
    end

   defp makePDFLinks(text, options) do
     case options[:mode] do
       "index" ->
          Regex.replace(~r/display::((http|https):(.*(pdf)))\s/U, " "<>text<>" ", "<a href=\"\\1\" target=\"_blank\">PDF FILE</a>")
       "show" ->
          Regex.replace(~r/display::((http|https):(.*(pdf)))\s/U, " "<>text<>" ", "<a href=\"\\1\" target=\"_blank\">PDF FILE </a> <iframe style='height:1000px; width:100%' src=\"\\1\"></iframe> ")
        _ ->
          Regex.replace(~r/display::((http|https):(.*(pdf)))\s/U, " "<>text<>" ", "<a href=\"\\1\" target=\"_blank\">PDF FILE </a>")
     end
   end

   def word_count(text) do
      text
      |> String.split(~r/\s/)
      |> length
   end

   defp erase_words(text, kill_words) do
     Enum.reduce(kill_words, text, fn(kill_word, text) -> String.replace(text, "#{kill_word} ", "") end)
   end

   defp highlight(text) do
     Regex.replace(~r/#(\S.*)#/U, text, "<span style='color:darkred;'>\\1</span>")
   end

   # https://lookupnote.herokuapp.com/notes/439?index=0&previous=439&next=439&id_list=439

   defp formatXREF(text) do
     # Regex.replace(~r/xref::([0-9]*)\[(.*)\]/U, text, "<a href=\"#{Constant.home_site}/notes/\\1?index=0&previous=\\1&next=\\1&id_string=\\1\">\\2</a>")
     Regex.replace(~r/xref::(.*)\[(.*)\]/U, text, "<a href=\"#{Constant.home_site}/notes/\\1?index=0&previous=\\1&next=\\1&id_string=\\1\">\\2</a>")
   end

   defp formatXREF2(text) do
        # Regex.replace(~r/xref::([0-9]*)\[(.*)\]/U, text, "<a href=\"#{Constant.home_site}/notes/\\1?index=0&previous=\\1&next=\\1&id_string=\\1\">\\2</a>")
        Regex.replace(~r/xref::(.*)\[(.*)\]/U, text, "<a href=\"#{Constant.home_site}/notes/\\1?mode=aside</a>")
      end

   ########## collate ###########

   defp random_string(length) do
     :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
   end

   def get_identifier(id) do
     note = Repo.get!(Note, id)
     if note.identifier == nil do
       identifier = note.username <> "." <> random_string(4) <> "-" <> random_string(4)
       params = %{"identifier" => identifier}
       changeset = Note.changeset(note, params)
       Repo.update(changeset)
     else
       Repo.get!(Note, id).identifier
     end
     identifier
   end

   defp prepare_item(item, prefix) do
       cond do
         is_integer(item) -> Repo.get!(Note, item).identifier
         Regex.match?(~r/^[1-9].[0-9]*/, item) -> Repo.get!(Note, String.to_integer(item)).identifier
         true -> "#{prefix}.#{item}"
       end
   end

   defp prepare_for_collation(text, options) do
     # split input into lines
     [user_info|data] = String.split(String.trim(text), ["\n", "\r", "\r\n"])
     # remove empty items
     |> Enum.filter(fn(item) -> item != "" end)
     # remove comments:
     |> Enum.map(fn(item) -> Regex.replace(~r/(.*)\s*\#.*$/U, item, "\\1") end)
     [_, username] = String.split(user_info, "=")

     data |> Enum.map(fn(item) -> prepare_item(item, username) end)
     |> Enum.filter(fn(item) -> Regex.match?(~r/^#{username}\./, item) end)
   end

   defp collate_one(id, str) do
     note = Note.get(id)
     str <> "\n\n" <> "== " <> note.title <> "\n\n" <> note.content <> "\n\n"
   end

   defp collate_one_public(id, str) do
     note = Note.get(id)
     if note.public == true do
       str <> "\n\n" <> "== " <> note.title <> "\n\n" <> note.content <> "\n\n"
     else
       str
     end
   end

   defp collate(input_text, options) do
     cond do
       options.collate == true && options.public == true ->
         prepare_for_collation(input_text, options)
                 |> Enum.reduce("", fn(id, acc) -> collate_one_public(id, acc) end)
       options.collate == true && options.public == false ->
         prepare_for_collation(input_text, options)
          |> Enum.reduce("", fn(id, acc) -> collate_one(id, acc) end)
       true ->
          input_text
     end
   end

  ######## processTOC #######

    defp make_toc_item(line, master_note_id) do
      [id, label] = String.split(line, ",")
      "<p><a href=\"#{Constant.home_site}/show2/#{master_note_id}/#{id}\">#{label}</a></p>"
    end

    defp prepare_toc(text, options) do
       # split input into lines
       lines = String.split(String.trim(text), ["\n", "\r", "\r\n"])
       # remove empty items
       |> Enum.filter(fn(item) -> item != "" end)
       # remove comments:
       |> Enum.map(fn(item) -> Regex.replace(~r/(.*)\s*\#.*$/U, item, "\\1") end)
       |> Enum.map(fn(line) -> make_toc_item(line, options.note_id) end)
    end

    defp do_processTOC(text, options) do
      prepare_toc(text, options)
      |> Enum.reduce("", fn(item, acc) -> acc <> item end)
    end

    defp processTOC(text, options) do
      Utility.report("processTOC, options", options)
      cond do
        options.toc == true -> do_processTOC(text, options)
        options.toc == false ->  text

        end
    end




  ############################

   # Need tests for this:
   defp ok_to_collate(user_id, id) do
     note = Repo.get!(Note, id)
     note.public || note.user_id == user_id
   end

   defp filter_id_list(id_list, user_id) do
     id_list |> Enum.filter(fn(id) -> ok_to_collate(user_id, id) end)
   end

   ######################################
end