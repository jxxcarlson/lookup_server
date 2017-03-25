defmodule MU.Scholar do

    def formatAnswer(text) do
       Regex.replace(~r/answer:\[(.*)\]/U, text, "<p><span id=\"QQ\" class=\"answer_head\">Answer:</span> <span id=\"QQA\" class=\"hide_answer\">\\1</span></p>")
    end

    def indexWord(text) do
      Regex.replace(~r/index:\[(.*)\]/U, text, "<span class=\"index_word\">\\1</span>")
    end

end
