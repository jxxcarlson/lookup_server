defmodule RegexTest do

   use LookupPhoenix.ModelCase
   import MU.Regex

   alias LookupPhoenix.Utility

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

    test "blurb_regex" do

      text = "yada yada\n[blurb]\n--\nho ho ho\n--\n"
      text2 = "yada yada\r\n[blurb]\r\n--\r\nho ho ho\r\n--\r\n"
      result = Regex.scan(blurb_regex(), text)
      [triple] = result
      [target, block_type, contents] = triple
      assert block_type == "blurb"
      assert contents == "\nho ho ho\n"

    end

 end
