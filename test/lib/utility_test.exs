defmodule UtilityTest do
  use LookupPhoenix.ModelCase

  alias LookupPhoenix.Utility

  test "firstWord extracts the first word from a text string" do
     input = "Jerzy Foobar"
     output = Utility.firstWord(input)
     assert output == "Jerzy"
  end

  test "add_index_to_maplist1" do
    maplist = [%{title: "foo"}, %{title: "bar"}, %{title: "baz"}]
    output = Utility.add_index_to_maplist1(maplist)
    expected_output = [%{title: "foo", index: 0}, %{title: "bar", index: 1}, %{title: "baz", index: 2}]
    IO.inspect expected_output
  end

  test "add_index_to_maplist" do
      maplist = [%{title: "foo"}, %{title: "bar"}, %{title: "baz"}]
      output = Utility.add_index_to_maplist(maplist)
      expected_output = [%{index: 0, title: "foo"}, %{index: 1, title: "bar"}, %{index: 2, title: "baz"}]
      assert output == expected_output
      IO.inspect output
   end

   test "parse_query_string" do
      input = "index=5&previous=333&next=777"
      output = Utility.parse_query_string(input)
      expected_output = %{"index" => "5", "next" => "777", "previous" => "333"}
      assert output == expected_output
      assert output["index"] == "5"
      IO.inspect output
   end


end