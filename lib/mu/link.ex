defmodule MU.Link do

  alias LookupPhoenix.Constant


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

    def siteLink(text) do
      Regex.replace(~r/site:(.*)\[(.*)\]/U, text,  " <a href=\"#{LookupPhoenix.Constant.home_site}/site/\\1\" target=\"_blank\">\\2</a> ")
    end

    # http://foo.io/ladidah/mo/stuff => <a href="http://foo.io/ladida/foo.io"" target=\"_blank\">foo.io/ladidah</a>
    # recognize URL[LINK TEXT]
    def makeUserLinks(text) do
      # Regex.replace(~r/\s((http|https):\/\/[a-zA-Z0-9\.\-\/&=~\?#!@_%-']*)\[(.*)\]\s/, " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
      Regex.replace(~r/\s(((http|https):\/\/[a-zA-Z0-9\.\-\/&=~\?#!@_%-']*)\[(.*)\])[^\]]/U, text,  " <a href=\"\\2\" target=\"_blank\">\\4</a> ")
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

  # https://lookupnote.herokuapp.com/notes/439?index=0&previous=439&next=439&id_list=439

   def formatXREF(text) do
     # Regex.replace(~r/xref::([0-9]*)\[(.*)\]/U, text, "<a href=\"#{Constant.home_site}/notes/\\1?index=0&previous=\\1&next=\\1&id_string=\\1\">\\2</a>")
     Regex.replace(~r/xref::(.*)\[(.*)\]/U, text, "<a href=\"#{Constant.home_site}/notes/\\1?index=0&previous=\\1&next=\\1&id_string=\\1\">\\2</a>")
   end

   def formatXREF2(text) do
        # Regex.replace(~r/xref::([0-9]*)\[(.*)\]/U, text, "<a href=\"#{Constant.home_site}/notes/\\1?index=0&previous=\\1&next=\\1&id_string=\\1\">\\2</a>")
        Regex.replace(~r/xref::(.*)\[(.*)\]/U, text, "<a href=\"#{Constant.home_site}/notes/\\1?mode=aside</a>")
      end

end
