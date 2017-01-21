defmodule UtilityTest do
  use LookupPhoenix.ModelCase

  alias LookupPhoenix.Utility

  test "firstWord extracts the first word from a text string" do
     input = "Jerzy Foobar"
     output = Utility.firstWord(input)
     assert output == "Jerzy"
  end


end