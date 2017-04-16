defmodule BlockTest do
  use LookupPhoenix.ModelCase
  alias LookupPhoenix.Utility
  alias MU.Block

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
expected_output = %{equation_counter: 0, text: "la di dah\n<div class='quote'>\nThis is\na test\n\n-- </div>\nfee\nfie\nfo\n"}
  output = Block.transform(text1)
  assert output == expected_output

  end

   test "formatCode" do

      text = "yada yada\n[code]\n--\na == b\n--\n"
      result = Block.formatCode(text)
      assert result == "yada yada\n<pre><code>\na == b\n</code></pre>"

    end


end