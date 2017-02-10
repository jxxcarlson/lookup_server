defmodule UtilityTest do
  use LookupPhoenix.ModelCase

  alias LookupPhoenix.Utility

  test "firstWord extracts the first word from a text string" do
     input = "Jerzy Foobar"
     output = Utility.firstWord(input)
     assert output == "Jerzy"
  end

  test "add_index_to_maplist" do
    maplist = [%{title: "foo"}, %{title: "bar"}, %{title: "baz"}]
    output = Utility.add_index_to_maplist(maplist)
    expected_output = [%{title: "foo", index: 0}, %{title: "bar", index: 1}, %{title: "baz", index: 2}]
    IO.inspect expected_output
  end


end