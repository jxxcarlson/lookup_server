defmodule RenderTextTest do
  use LookupPhoenix.ModelCase


  test "smartLinks parses example 1" do
     argument = "https://stripe.com"
     link_text = "stripe.com"
     result =  RenderText.makeSmartLinks(argument)
     expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
     assert String.trim(result) ==  String.trim(expected)
  end

  test "smartLinks parses example 2" do
      argument = "https://stripe.com/"
      link_text = "stripe.com"
      result =  RenderText.makeSmartLinks(argument)
      expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
      assert String.trim(result) ==  String.trim(expected)
  end

  test "smartLinks parses example 3" do
      argument = "https://stripe.com/a/b/c"
      link_text = "stripe.com"
      result =  RenderText.makeSmartLinks(argument)
      expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
      assert String.trim(result) ==  String.trim(expected)
  end

   test "smartLinks parses example 4" do
        argument = "https://stripe.com?foo=bar"
        link_text = "stripe.com"
        result =  RenderText.makeSmartLinks(argument)
        expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
        assert String.trim(result) ==  String.trim(expected)
   end

   test "smartLinks parses example 5" do
           argument = "https://medium.com/@_rchaves_/testing-in-elm-93ad05ee1832#.gk2ch6hz0"
           link_text = "medium.com"
           result =  RenderText.makeSmartLinks(argument)
           expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
           assert String.trim(result) ==  String.trim(expected)
   end


    test "smartLinks parses example 6" do
           argument = "http://www.rsc.org/learn%3C/span%3E-chemistry/resource/res00000466/the-electrolysis-of-solutions"
           link_text = "www.rsc.org"
           result =  RenderText.makeSmartLinks(argument)
           expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
           assert String.trim(result) ==  String.trim(expected)
   end

    test "smartLinks parses example 7" do
              argument = "http://noredink.github.io/json-to-elm/"
              link_text = "noredink.github.io"
              result =  RenderText.makeSmartLinks(argument)
              expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
              assert String.trim(result) ==  String.trim(expected)
      end

# http://noredink.github.io/json-to-elm/

   test "transform parses example in list item" do
     argument = """

- http://noredink.github.io/json-to-elm/

"""
     link_text = "noredink.github.io"
     result = RenderText.transform(argument)
     expected = "<span style='padding-left:20px; text-indent:-20px;margin-bottom:0em;margin-top:0em;'>-  <a href=\"http://noredink.github.io/json-to-elm/\" target=\"_blank\">noredink.github.io</a></span>"
     assert String.trim(result) ==  String.trim(expected)
   end

   test "userLinks parses example 1" do
     url = "https://www.itp.uni-hannover.de/teaching/Open2014/master.pdf"
     link_text = "Quantum Master Equations (Hannover)"
     full_url = url <> "[#{link_text}]"
     result =  RenderText.makeUserLinks(full_url)
     expected = "<a href=\"#{url}\" target=\"_blank\">#{link_text}</a>"
     assert String.trim(result) ==  String.trim(expected)
   end

   test "userLinks parses example 2" do
     url = "https://www.itp.uni-hannover.de/~weimer/teaching/Open2014/master.pdf"
     link_text = "Quantum Master Equations (Hannover)"
     full_url = url <> "[#{link_text}]"
     result =  RenderText.makeUserLinks(full_url)
     expected = "<a href=\"#{url}\" target=\"_blank\">#{link_text}</a>"
     assert String.trim(result) ==  String.trim(expected)
   end

   test "formatInlineCode regex" do
         input = "ho ho `foo := bar` ha ha"
         output = RenderText.formatInlineCode(input)
         expected_output = "ho ho <tt style='color:darkred; font-weight:400'>foo := bar</tt> ha ha"
         assert output == expected_output
   end

   test "apply strikethrough" do
     input = "ss  -Call Reza- eee"
     output = RenderText.padString(input) |> RenderText.formatStrike |> String.trim
     expected_output="<span style='text-decoration: line-through'>Call Reza</span>"
     assert output == expected_output
   end

   test "apply_markdown regex" do
       input = "ho ho `foo := bar` ha ha"
       output = RenderText.apply_markdown(input) |> String.trim
       expected_output = "ho ho <tt style='color:darkred; font-weight:400'>foo := bar</tt> ha ha"
       assert output == expected_output
   end

   test "transform regex" do
        input = "ho ho `foo := bar` ha ha"
        output = RenderText.transform(input)
        expected_output = "ho ho <tt style='color:darkred; font-weight:400'>foo := bar</tt> ha ha"
        assert output == expected_output
   end

   test "formatCode" do
input = """

----
a == b
----
foo, bar
----
c == d
----

"""
   output = RenderText.formatCode(input)
   expected_output = """
<pre>
a == b
</pre>
foo, bar
<pre>
c == d
</pre>
"""
   clean_output = Regex.replace(~r/\s/, output, "")
   clean_expected_utput = Regex.replace(~r/\s/, expected_output, "")

    assert  clean_output == clean_expected_utput
   end

test "transform" do
input = """

----
a == b
----
foo, bar
----
c == d
----

"""
   output = RenderText.transform(input)
   expected_output = """
<pre>
a == b
</pre>
foo, bar
<pre>
c == d
</pre>
"""
   clean_output = Regex.replace(~r/\s/, output, "")
   clean_expected_utput = Regex.replace(~r/\s/, expected_output, "")

    assert  clean_output == clean_expected_utput
   end

   test "get urls" do
     input = "abc http://foo.io def http://bar.io?yada=yada"
     output = RenderText.getURLs(input)
     expected_output = ["http://foo.io", "http://bar.io?yada=yada"]
     assert output == expected_output
   end

   test "prep urls" do
     input = "abc http://foo.io def http://bar.io?yada=yada"
     output = RenderText.getURLs(input) |> RenderText.prepURLs
     expected_output = [["http://foo.io", "http://foo.io"], ["http://bar.io?yada=yada", "http://bar.io"]]
     assert output == expected_output
   end

   test "simplify one url" do
      input = "abc http://foo.io?a=b def http://bar.io?yada=yada ho ho ho"
      substitution_list = RenderText.getURLs(input) |> RenderText.prepURLs
      substitution_item = hd(substitution_list)
      output = RenderText.simplify_one_URL(substitution_item, input)
      expected_output = "abc http://foo.io def http://bar.io?yada=yada ho ho ho"
      assert output == expected_output
   end

   test "simplify urls" do
      input = "abc http://foo.io def http://bar.io?yada=yada ho ho ho"
      output = RenderText.simplifyURLs(input)
      expected_output = "abc http://foo.io def http://bar.io ho ho ho"
      assert output == expected_output
   end

    test "simplify urls II" do
      input = "abc image::http://foo.io/hoho.jpg def image::http://bar.io/a/b/c/umdo.jpg?yada=yada ho ho ho"
      output = RenderText.simplifyURLs(input)
      expected_output = "abc image::http://foo.io/hoho.jpg def image::http://bar.io/a/b/c/umdo.jpg ho ho ho"
      assert output == expected_output
    end

    test "preprocess image URLs" do
      input = "abc http://foo.io/hoho.jpg def http://bar.io/a/b/c/umdo.PNG ho ho ho"
      output = RenderText.preprocessImageURLs(input)
      expected_output = "abc image::http://foo.io/hoho.jpg def image::http://bar.io/a/b/c/umdo.PNG ho ho ho"
      assert output == expected_output
    end

    test "getItems returns a list of 'items' when threre is just one item" do
          text = """
- item one

blah, blah
"""

        items = RenderText.getItems(text)
        assert length(items) == 1
        assert hd(items) == "item one"
        end

    test "getItems returns a list of 'items'" do
      text = """
Foo, bar
- item one
- item two

- item three

blah, blah
"""

    items = RenderText.getItems(text)
    assert length(items) == 3
    assert hd(items) == "item one"
    assert hd(tl(items)) == "item two"
    assert hd(tl(tl(items))) == "item three"

    end

    test "RenderText.formatItems ...'" do
      text = """
Foo, bar
- item one
- item two

- item three

blah, blah
"""

    items = RenderText.getItems(text)
    assert length(items) == 3
    assert hd(items) == "item one"
    assert hd(tl(items)) == "item two"
    assert hd(tl(tl(items))) == "item three"

    item_one = hd(items)

    assert RenderText.formatItems(text) ==  "Foo, bar\n<span style='padding-left:20px; text-indent:-20px;margin-bottom:0em;margin-top:0em;'>-  item one</span>\n<span style='padding-left:20px; text-indent:-20px;margin-bottom:0em;margin-top:0em;'>-  item two</span>\n\n<span style='padding-left:20px; text-indent:-20px;margin-bottom:0em;margin-top:0em;'>-  item three</span>\n\nblah, blah\n"
    end

    test "getItems when there are no items ...'" do
       text = """
 Foo, bar
 blah, blah
 """

     items = RenderText.getItems(text)
     assert length(items) == 0

    end

  test "word count" do
    input = "abc def"
    output = RenderText.word_count(input)
    expected_output = 2
    assert output == expected_output
   end


   test "erase words 1" do
     text = "this is a :foo test hohoho :bar hahaha"
     kill_words = [":foo", ":bar"]
     expected_output = "this is a test hohoho hahaha"
     output = Enum.reduce(kill_words, text, fn(kill_word, text) -> String.replace(text, "#{kill_word} ", "") end)
     assert output == expected_output
   end

   test "erase words" do
     input = "this is a :foo test hohoho :bar hahaha"
     expected_output = "this is a test hohoho hahaha"
     output = RenderText.erase_words(input, [":foo", ":bar"])
     assert output == expected_output
   end

 end
