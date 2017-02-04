defmodule RenderText do

############# PUBLIC ##################

    def transform(text, height \\ 200) do
      text
      |> String.trim
      |> padString
      |> linkify(height)
      |> apply_markdown
      |> String.trim
      |> insert_mathjax
    end

    def preprocessURLs(text) do
      text
      |> padString
      |> simplifyURLs
      |> preprocessImageURLs
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
      |> linkify
      |> formatBold
      |> formatRed
      |> formatItalic
    end

    ############# PRIVATE ##################


    def padString(text) do
      "\n" <> text <> "\n"
    end


    def linkify(text, height \\ 200) do
      text
      |> simplifyURLs
      |> makeUserLinks
      |> makeSmartLinks
      |> makeImageLinks(height)
      |> String.trim
    end

    def apply_markdown(text) do
      text
      |> formatCode
      |> formatInlineCode
      |> padString
      |> formatStrike
      |> formatBold
      |> formatItalic
      |> formatMDash
      |> formatNDash
      |> formatRed
      |> padString
      |> formatItems
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
      # Regex.replace(~r/\s((http|https):\/\/\S*\.(jpg|jpeg|png))\s/i, text, "image::\\1 ")
      Regex.replace(~r/[^:]((http|https):\/\/\S*\.(jpg|jpeg|png))\s/i, text, " image::\\1 ")
    end

    def makeDumbLinks(text) do
      Regex.replace(~r/\s((http|https):\/\/[a-zA-Z0-9\.\-\/&=\?#!@_%]*)\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">LINK</a> ")
    end

    # ha ha http://foo.bar.io/a/b/c blah blah => 1: http://foo.bar.io/a/b/c, 3: foo.bar.io
    def makeSmartLinks(text) do
       Regex.replace(~r/\s((http|https):\/\/([a-zA-Z0-9\.\-_%-]*)([\/?=#]\S*|))\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
    end

    # http://foo.io/ladidah/mo/stuff => <a href="http://foo.io/ladida/foo.io"" target=\"_blank\">foo.io/ladidah</a>
    def makeUserLinks(text) do
      Regex.replace(~r/\s((http|https):\/\/[a-zA-Z0-9\.\-\/&=~\?#!@_%-]*)\[(.*)\]\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
    end

    def makeImageLinks(text, height \\ 200) do
       Regex.replace(~r/\simage::(.*(png|jpg|jpeg|JPG|JPEG|PNG))\s/, " "<>text<>" ", " <img src=\"\\1\" height=#{height}> ")
    end

    def formatNDash(text) do
      # \s(--)\s
      Regex.replace(~r/\s(--) /, text, " &ndash; ")
    end

    def formatMDash(text) do
       Regex.replace(~r/\s(---) /, text, " &mdash; ")
    end

    def formatStrike(text) do
       Regex.replace(~r/\s-(.*)-\s/U, text, " <span style='text-decoration: line-through'>\\1</span> ")
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

    def formatItem(item) do
      "<span style='padding-left:20px; text-indent:-20px;margin-bottom:0em;margin-top:0em;'>-  #{item}</span>"
    end

    def formatInlineCode(text) do
      Regex.replace(~r/\`(.*)\`/U, text, "<tt style='color:darkred; font-weight:400'>\\1</tt>")
    end

    def formatCode(text) do
      Regex.replace(~r/----(?:\r\n|[\r\n])(.*)(?:\r\n|[\r\n])----/msr, text, "<pre style='margin-bottom:-1.2em;;'>\\1</pre>")
    end

    # ``\n(.*)\n```

    def formatBold(text) do
       Regex.replace(~r/(\*(.*)\*)/U, text, "<strong>\\2</strong>")
    end

    def formatItalic(text) do
       Regex.replace(~r/\s_(.*)_\s/U, text, " <i>\\1</i> ")
    end

    def formatRed(text) do
       Regex.replace(~r/red:\[(.*)\]/U, text, "<span style='color:darkred;'>\\1</span>")
    end

    def scrubTags(text) do
      Regex.replace(~r/\s:.*\s/, " " <> text <> " ",    " ")
    end


    # TeX: { extensions: ["mhchem.js"] }

    def insert_mathjax!(text) do
      text <>  """

          <script type="text/x-mathjax-config">
            MathJax.Hub.Config( {tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}, TeX: { extensions: ["mhchem.js"] } });

          </script>
              <script type="text/javascript" async
                      src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_CHTML">
           </script>

"""
    end

    def identity(text) do
      text
    end

    def insert_mathjax(text) do
      if Regex.match?(~r/:latex/, text) do
        text = insert_mathjax!(text)
        Regex.replace(~r/:latex/, text, "")
      else
        text
      end
    end

end