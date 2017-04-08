defmodule MU.Paragraph do

  alias LookupPhoenix.Utility

  def format(text) do
    paragraphs = String.split(text, ["\n\n", "\r\r", "\r\n\r\n"])
    |> Enum.map(fn(paragraph) -> " " <> String.trim(paragraph) <> " " end)
    |> Enum.reduce( "", fn(paragraph, acc) -> acc <> "<p> #{paragraph} </p>\n" end)
  end

end