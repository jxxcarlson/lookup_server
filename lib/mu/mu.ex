defmodule MU.RenderText do
  alias LookupPhoenix.Repo
  alias LookupPhoenix.Note
  alias LookupPhoenix.Utility

  alias MU.Paragraph
  alias MU.Inline
  alias MU.Section
  alias MU.Block
  alias MU.List
  alias MU.Table
  alias MU.Link

  alias MU.MathSci
  alias MU.Scholar

  alias MU.TOC
  alias MU.Collate

    # mode = plain | markup | latex | collate | toc

    def transform(text, options \\ %{mode: "show", process: "markup"}) do
      # Utility.report "IN TRANSFORM TEXT, OPTIONS ARE", options
      begin_time = Timex.now
      result = case options.process do
        "plain" -> text
        "markup" -> format_markup(text, options) |> filterComments
        "latex" -> format_latex(text, options)  |> filterComments
        "collate" -> Collate.collate(text, options) |> format_latex(options)  |> filterComments
        "toc" -> TOC.process(text, options)
        _ -> format_markup(text, options)
      end
      Utility.benchmark(begin_time, text, "0. MU.transform")
      result
    end

    defp pad_at_end(text) do
      text <> "\n\n\n\n"
    end

    defp format_markup(text, options) do
      text
      |> Section.format
      |> Block.transform
      |> Block.formatCode
      |> linkify(options)
      |> apply_markdown
      |> Paragraph.format
    end

    defp format_latex(text, options) do
      text
      |> format_markup(options)
      |> MathSci.formatChem
      |> MathSci.formatChemBlock
      |> MathSci.insert_mathjax(options)
    end

    def firstParagraph(text) do
      short_text = Regex.run(~r/.*\s\s/, text)
      case short_text do
        nil -> text
        [] -> text
        _ -> (hd short_text) <> " •••"
      end
    end

    def head_excerpt(text, n_words) do
      text
      |> String.split(" ")
      |> Enum.slice(0..(n_words-1))
      |> Enum.join(" ")
    end

    def format_for_index(text) do
      text
      |> Block.formatBlurb
      |> linkify(%{mode: "index", process: "node"})
      |> Inline.formatBold
      |> Inline.formatRed
      |> Inline.formatItalic
      |> Inline.formatInlineCode
      |> Inline.highlight
    end

    defp padString(text) do
      "\n" <> text <> "\n"
    end


    defp linkify(text, options) do
      begin_time = Timex.now
      result = text
      |> Link.makeYouTubePlayer(options)
      |> Link.makeAudioPlayer
      |> Link.makeImageLinks(options)
      |> Link.makeFormattedImageLinks(options)
      |> Link.formatHyperlink2
      |> Link.formatHyperlink
      |> Link.makePDFLinks(options)
      |> Link.siteLink
      Utility.benchmark(begin_time, text, "2. MU.linkify")
      result
    end

    defp apply_markdown(text) do
      text
      |> Table.format
      |> Block.formatCode
      |> Block.formatVerbatim
      |> Inline.transform
      |> Scholar.indexWord
      |> List.formatItems
      |> Scholar.formatAnswer
      |> Link.formatXREF
    end

    defp filterComments(text) do
      String.split(text, ["\r", "\n", "\rn"]) |> Enum.filter(fn(line) -> !Regex.match?(~r/^\/\//, line) end) |> Enum.join("\n")
    end

    defp scrubTags(text) do
      Regex.replace(~r/\s:.*\s/, " " <> text <> " ",    " ")
    end

   def word_count(text) do
      text
      |> String.split(~r/\s/)
      |> length
   end

   defp erase_words(text, kill_words) do
     Enum.reduce(kill_words, text, fn(kill_word, text) -> String.replace(text, "#{kill_word} ", "") end)
   end

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

   # Need tests for this:
   defp ok_to_collate(user_id, id) do
     note = Repo.get!(Note, id)
     note.public || note.user_id == user_id
   end

   defp filter_id_list(id_list, user_id) do
     id_list |> Enum.filter(fn(id) -> ok_to_collate(user_id, id) end)
   end

end