defmodule RenderText do
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Note
  alias LookupPhoenix.Utility

############# PUBLIC ##################

    def transform(input_text, options \\ %{mode: "show", process: "none", collate: false}) do
      Utility.report("TT, OPTIONS", options)
      if options.collate == true do
        id_list = String.split(input_text, ",")
        |> Enum.map(fn(item) -> String.trim(item) end)
        |> Enum.map(fn(item) -> String.to_integer(item) end)
        |> RenderText.filter_id_list(options.user_id)
        Utility.report("ID LIST", id_list)
        text = collate(id_list)
      else
        text = input_text
      end
      text
      |> String.trim
      # |> formatVerbatim
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


    def padString(text) do
      "\n" <> text <> "\n"
    end


    def linkify(text, options) do
      text
      # |> simplifyURLs
      |> makeYouTubePlayer(options)
      |> makeAudioPlayer
      |> makeImageLinks(options)
      |> makeFormattedImageLinks(options)
      |> makeUserLinks
      |> makeSmartLinks
      |> makePDFLinks(options)
      |> String.trim
    end

    def apply_markdown(text) do
      text
      |> padString
      |> formatVerbatim
      |> formatCode
      |> formatInlineCode
      |> padString
      |> formatBold
      |> formatItalic
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

    def getURLs(text) do
      Regex.scan(~r/((http|https):\/\/\S*)\s/, " " <> text <> " ", [:all])
      |> Enum.map(fn(x) -> hd(tl(x)) end)
    end

    def prepURLs(url_list) do
       Enum.map(url_list, fn(x) -> [x, hd(String.split(x, "?"))] end)
    end

    def simplify_one_URL(substitution_item, text) do
      target = hd(substitution_item)
      replacement = hd(tl(substitution_item))
      String.replace(text, target, replacement)
    end

    def simplifyURLs(text) do
      url_substitution_list = text |> getURLs |> prepURLs
      Enum.reduce(url_substitution_list, text, fn(substitution_item, text) -> simplify_one_URL(substitution_item, text) end)
    end

    def preprocessImageURLs(text) do
      Regex.replace(~r/[^:]((http|https):\/\/\S*\.(jpg|jpeg|png|gif))\s/i, text, " image::\\1 ")
    end

    def makeDumbLinks(text) do
      Regex.replace(~r/\s((http|https):\/\/[a-zA-Z0-9\.\-\/&=\?#!@_%]*)\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">LINK</a> ")
    end

    # ha ha http://foo.bar.io/a/b/c blah blah => 1: http://foo.bar.io/a/b/c, 3: foo.bar.io
    def makeSmartLinks(text) do
       #Regex.replace(~r/\s((http|https):\/\/([a-zA-Z0-9\.\-_%-]*)([\/?=#]\S*|))\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
       Regex.replace(~r/\s((http|https):\/\/([a-zA-Z0-9\.\-_%-']*)([\/?=#]\S*|))\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
    end

    # http://foo.io/ladidah/mo/stuff => <a href="http://foo.io/ladida/foo.io"" target=\"_blank\">foo.io/ladidah</a>
    def makeUserLinks(text) do
      Regex.replace(~r/\s((http|https):\/\/[a-zA-Z0-9\.\-\/&=~\?#!@_%-']*)\[(.*)\]\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
    end

    def makeAudioPlayer(text) do

       Regex.replace(~r/(http|https):\/\/(.*(mp3|wav))/i, " "<>text<>" ", "<audio controls> <source src=\"\\0\" type=\"audio/\\3\" >Your browser does not support the audio element.</audio>")

    end

    def makeImageLinks1(text, options) do
       case options[:mode] do
         "index" ->
           Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
         "show" ->
           Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" height=\"600px\" > ")
         #_ ->
         #  Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
       end

    end

    def makeImageLinks(text, options) do
       case options[:mode] do
         "index" ->
           Regex.replace(~r/(http|https):\/\/(.*(png|jpg|jpeg|gif))(\s|$)/i, " "<>text<>" ", " <img src=\"\\0\" width=\"120px\" height=\"120px\" > ")
         "show" ->
           Regex.replace(~r/(http|https):\/\/(.*(png|jpg|jpeg|gif))(\s|$)/i, " "<>text<>" ", " <img src=\"\\0\" height=\"300px\" > ")
         #_ ->
         #  Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
       end

    end

    def makeFormattedImageLinks(text, options) do
       case options[:mode] do
         "index" ->
           Regex.replace(~r/((http|https):\/\/(.*(png|jpg|jpeg|gif)))\[(.*)\]/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
         "show" ->
           Regex.replace(~r/((http|https):\/\/(.*(png|jpg|jpeg|gif)))\[(.*)\]/i, " "<>text<>" ", " <img src=\"\\1\" style=\"\\5\" > ")
         #_ ->
         #  Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
       end

    end

    def makeYouTubePlayer(text, options) do
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


    def formatNDash(text) do
      # \s(--)\s
      Regex.replace(~r/\s(--) /, text, " &ndash; ")
    end

    def formatMDash(text) do
       Regex.replace(~r/\s(---) /, text, " &mdash; ")
    end

    def formatStrike(text) do
       # Regex.replace(~r/(^|\s)-([^-]*)-(\s)/U, text, " <span style='text-decoration: line-through'>\\2</span> \\3")
       Regex.replace(~r/(^|\s)-([^-\s]*)-(\s)/U, text, "\\1<span style='text-decoration: line-through;color:darkred'>\\2</span>\\3")
    end

    def getItems(text) do
      Regex.scan(~r/^- (\S*.*)[\n\r]/msU, "\n" <> text)
      |> Enum.map(fn(x) -> hd(tl(x)) end)
      |> Enum.map(fn(item) -> String.trim(item) end)
    end


    def formatItems(text) do
       getItems(text)
       |> Enum.reduce(text, fn(item, text) -> String.replace(text, "- " <> item, formatItem(item)) end)
    end

    def formatItem  (item) do
      "<span style='margin-left:2em; text-indent:-0.7em;display:inline-block;margin-bottom:0.3em;'>-  #{item}</span>"
    end

    def formatInlineCode(text) do
      Regex.replace(~r/\`(.*)\`/U, text, "<tt style='color:darkred; font-weight:400'>\\1</tt>")
    end

    def formatVerbatim(text) do
      Regex.replace(~r/----(?:\r\n|[\r\n])(.*)(?:\r\n|[\r\n])----/msr, text, "<pre style='margin-bottom:-1.2em;;'>\\1</pre>")
    end

    # ``\n(.*)\n```

    def formatBold(text) do
       Regex.replace(~r/(\*(.*)\*)/U, text, "<strong>\\2</strong>")
    end

    def formatItalic(text) do
       Regex.replace(~r/(\s)_(.*)_(\s)/U, text, "\\1<i>\\2</i>\\3")
    end

    def formatRed(text) do
       Regex.replace(~r/red:\[(.*)\]/U, text, "<span style='color:darkred;'>\\1</span>")
    end

    def formatChem(text) do
      Regex.replace(~r/chem:\[(.*)\]/U, text, "$\\ce{\\1}$")
    end

    def formatChemBlock(text) do
      Regex.replace(~r/chem::\[(.*)\]/U, text, "$$\\ce{\\1}$$")
    end

    def formatCode(text) do
      Regex.replace(~r/\[code\]\n--\n(.*)\n--/mU, text, "<pre><code>\\n#\\1\\n</code></pre>")
    end

    def formatAnswer(text) do
       Regex.replace(~r/answer:\[(.*)\]/U, text, "<p><span id=\"QQ\" class=\"answer_head\">Answer:</span> <span id=\"QQA\" class=\"hide_answer\">\\1</span></p>")
    end

    def formatVerbatim(text) do
      Regex.replace(~r/verbatim:\[(.*)\]/U, text, "<pre>\\1</pre>")
    end

    def scrubTags(text) do
      Regex.replace(~r/\s:.*\s/, " " <> text <> " ",    " ")
    end




    def insert_mathjax!(text) do

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


    def insert_mathjax(text, options) do
      if options[:process] == "latex" do
        text = insert_mathjax!(text)
      else
        text
      end
    end

   def makePDFLinks(text, options) do
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

   def erase_words(text, kill_words) do
     Enum.reduce(kill_words, text, fn(kill_word, text) -> String.replace(text, "#{kill_word} ", "") end)
   end

   def highlight(text) do
     Regex.replace(~r/#(\S.*)#/U, text, "<span style='color:darkred;'>\\1</span>")
   end

   # https://lookupnote.herokuapp.com/notes/439?index=0&previous=439&next=439&id_list=439

   def formatXREF(text) do
     Regex.replace(~r/xref::([0-9]*)\[(.*)\]/U, text, "<a href=\"https://lookupnote.herokuapp.com/notes/\\1?index=0&previous=\\1&next=\\1&id_string=\\1\">\\2</a>")
   end

   def collate_one(id, str) do
     note = Repo.get!(Note, id)
     str <> "\n\n" <> "== " <> note.title <> "\n\n" <> note.content <> "\n\n"
   end

   def collate(id_list) do
     Enum.reduce(id_list, "", fn(id, acc) -> collate_one(id, acc) end)
   end

   # Need tests for this:
   def ok_to_collate(user_id, id) do
     note = Repo.get!(Note, id)
     note.public || note.user_id == user_id
   end

   def filter_id_list(id_list, user_id) do
     id_list |> Enum.filter(fn(id) -> ok_to_collate(user_id, id) end)
   end

end