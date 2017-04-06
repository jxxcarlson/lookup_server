defmodule MU.Scholar do

    alias LookupPhoenix.Utility

    def formatAnswer1(text) do
       Regex.replace(~r/answer:\[(.*)\]/U, text, "<p><span id=\"QQ\" class=\"answer_head\">Answer:</span> <span id=\"QQA\" class=\"hide_answer\">\\1</span></p>")
    end

    defp formatted_answer(answer) do
      identifier = random_string(4)
      "<p><span id=\"QQ.#{identifier}\" class=\"answer_head\">Answer:</span> <span id=\"QQ.#{identifier}.A\" class=\"hide_answer\">#{answer}</span></p>"
    end

    @doc """
    Format for a click block is
    [click, title=TITLE]
    --
    Text to be revealed by clicking
    --
"""

    def formatAnswer(text) do
       identifier = random_string(4)
       Regex.scan(~r/answer:\[(.*)\]/U, text)
       |> Enum.reduce(text, fn(item, text) -> String.replace(text, hd(item), formatted_answer(hd(tl(item)))) end)
    end


    def indexWord(text) do
      Regex.replace(~r/index:\[(.*)\]/U, text, "<span class=\"index_word\">\\1</span>")
    end

    defp random_string(length) do
      :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    end

end
