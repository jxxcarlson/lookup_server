defmodule MU.Paragraph do

  alias LookupPhoenix.Utility

  def format(text) do
    paragraphs = String.split(text, ["\n\n", "\r\r", "\r\n\r\n"])
    |> Enum.filter(fn(paragraph) -> Regex.match?(~r/\s*/mU, paragraph) end)
    |> Enum.map(fn(paragraph) -> " " <> String.trim(paragraph) <> " " end)
    |> Enum.reduce( "", fn(paragraph, acc) -> acc <> "<p>\n#{paragraph}\n</p>\n\n" end)
  end

end