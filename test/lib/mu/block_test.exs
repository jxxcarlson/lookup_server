defmodule BlockTest do
  use LookupPhoenix.ModelCase
  alias LookupPhoenix.Utility
  alias LookupPhoenix.Block

  test "parse block" do
    text1 = """
la di dah
[quote]
--
This is
a test
--
fee
fie
fo
"""
  output = Block.transform(text1)
  assert output == "la di dah\n<div class='quote'>\nThis is\na test\n</div>\n\nfee\nfie\nfo\n"

  end


end