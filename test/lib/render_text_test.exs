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

   test "formatInlineCode regex" do
         input = "ho ho `foo := bar` ha ha"
         output = RenderText.formatInlineCode(input)
         expected_output = "ho ho <tt style='color:darkred; font-weight:400'>foo := bar</tt> ha ha"
         assert output == expected_output
   end

   test "apply strikethrough" do
     input = " -Call Reza- "
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

    test "getItems returns a list of 'items'''" do
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
    # assert RenderText.formatItem(item_one) == "<p style='margin-bottom:-1em; margin-top:0; padding-left:20px; text-indent:-20px;'>-  item one</p>"

    IO.puts "=================="
    IO.inspect items
    IO.puts "=================="
    assert RenderText.formatItems(text) ==  "Foo, bar\n<p style='padding-left:20px; text-indent:-20px;'>-  item one</p>\n<p style='padding-left:20px; text-indent:-20px;'>-  item two</p>\n\n<p style='padding-left:20px; text-indent:-20px;'>-  item three</p>\n\nblah, blah\n"
    end

end