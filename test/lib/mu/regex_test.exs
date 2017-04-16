defmodule RegexTest do

   use LookupPhoenix.ModelCase
   import MU.Regex


   test "regex with *" do

      text = "yada yada\n* Google: parsec parser combinator\nfoo, bar"
      result = Regex.scan(unordered_list_item_regex(), text)
      [[_| target]] = result
      assert target == ["Google: parsec parser combinator"]

   end

   test "code_regex" do

      text = "yada yada\n[code]\n--\na == b\n--\n"
      result = Regex.scan(code_regex(), text)
      [[_| target]] = result
      assert target == ["a == b"]

    end

 end
