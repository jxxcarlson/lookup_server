defmodule MU.Link do

  alias LookupPhoenix.Constant
  import MU.Regex

    # ha ha http://foo.bar.io/a/b/c blah blah => 1: http://foo.bar.io/a/b/c, 3: foo.bar.io
    def formatHyperlink(text) do
       Regex.replace(hyperlink_bare_regex(), " "<>text<>" ",  " <a href=\"\\1\" target=\"_blank\">\\3</a> ")
    end

    def siteLink(text) do
      Regex.replace(site_link_regex(), text,  " <a href=\"#{LookupPhoenix.Constant.home_site}/site/\\1\" target=\"_blank\">\\2</a> ")
    end

    # http://foo.io/ladidah/mo/stuff => <a href="http://foo.io/ladida/foo.io"" target=\"_blank\">foo.io/ladidah</a>
    # recognize URL[LINK TEXT]
    def formatHyperlink2(text) do
      Regex.replace(hyperlink_formatted_regex(), text,  " <a href=\"\\2\" target=\"_blank\">\\4</a> ")
    end

    def makeAudioPlayer(text) do
       Regex.replace(audio_player_regex(), " "<>text<>" ", "<audio controls> <source src=\"\\0\" type=\"audio/\\3\" >Your browser does not support the audio element.</audio>")
    end

    def makeImageLinks(text, options) do
       case options[:mode] do
         "index" ->
           Regex.replace(image_bare_regex(), " "<>text<>" ", " <img src=\"\\0\" width=\"120px\" height=\"120px\" > ")
         "show" ->
           Regex.replace(image_bare_regex(), " "<>text<>" ", " <img src=\"\\0\" height=\"300px\" > ")
         #_ ->
         #  Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
       end

    end

    def makeFormattedImageLinks(text, options) do
       case options[:mode] do
         "index" ->
           Regex.replace(image_regex_formatted(), " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
         "show" ->
           Regex.replace(image_regex_formatted(), " "<>text<>" ", " <img src=\"\\1\" style=\"\\5\" > ")
         #_ ->
         #  Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
       end

    end

    def makeYouTubePlayer(text, options) do
       case options[:mode] do
         "show" ->
           Regex.replace(youtube_regex(), " "<>text<>" ", "<iframe width=\"640\" height=\"360\" src=\"https://www.youtube.com/embed/\\2\"  frameborder=\"0\" allowfullscreen></iframe>")
         "index" ->
           Regex.replace(youtube_regex(), " "<>text<>" ", "<iframe width=\"213\" height=\"120\" src=\"https://www.youtube.com/embed/\\2\"  frameborder=\"0\" allowfullscreen></iframe>")
         #_ ->
         #  Regex.replace(~r/\simage::(.*(png|jpg|jpeg|gif))\s/i, " "<>text<>" ", " <img src=\"\\1\" width=\"120px\" height=\"120px\" > ")
       end

    end

   def makePDFLinks(text, options) do
     case options[:mode] do
       "index" ->
          Regex.replace(pdf_regex(), " "<>text<>" ", "<a href=\"\\1\" target=\"_blank\">PDF FILE</a>")
       "show" ->
          Regex.replace(pdf_regex(), " "<>text<>" ", "<a href=\"\\1\" target=\"_blank\">PDF FILE </a> <iframe style='height:1000px; width:100%' src=\"\\1\"></iframe> ")
        _ ->
          Regex.replace(pdf_regex(), " "<>text<>" ", "<a href=\"\\1\" target=\"_blank\">PDF FILE </a>")
     end
   end

  # https://lookupnote.herokuapp.com/notes/439?index=0&previous=439&next=439&id_list=439

   def formatXREF(text) do
     Regex.replace(xref_regex(), text, "<a href=\"#{Constant.home_site}/notes/\\1?index=0&previous=\\1&next=\\1&id_string=\\1\">\\2</a>")
   end


end
