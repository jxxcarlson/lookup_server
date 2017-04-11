defmodule RegexTest do

   use LookupPhoenix.ModelCase
   import MU.Regex


 test "regex with *" do

      text = "yada yada\n* Google: parsec parser combinator\nfoo, bar"
      result = Regex.scan(unordered_list_item_regex(), text)
      [[_| target]] = result
      assert target == ["Google: parsec parser combinator"]

   end


 end
