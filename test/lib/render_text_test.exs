defmodule RenderTextTest do
  use LookupPhoenix.ModelCase


  test "smartLinks parses example 1" do
     argument = "https://stripe.com"
     link_text = "stripe.com"
     result =  RenderText.transform(argument)
     expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
     assert String.trim(result) ==  String.trim(expected)
  end

  test "smartLinks parses example 2" do
      argument = "https://stripe.com/"
      link_text = "stripe.com"
      result =  RenderText.transform(argument)
      expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
      assert String.trim(result) ==  String.trim(expected)
  end

  test "smartLinks parses example 3" do
      argument = "https://stripe.com/a/b/c"
      link_text = "stripe.com"
      result =  RenderText.transform(argument)
      expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
      assert String.trim(result) ==  String.trim(expected)
  end

   test "smartLinks parses example 4" do
        argument = "https://stripe.com?foo=bar"
        link_text = "stripe.com"
        result =  RenderText.transform(argument)
        expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
        assert String.trim(result) ==  String.trim(expected)
   end

   test "smartLinks parses example 5" do
           argument = "https://medium.com/@_rchaves_/testing-in-elm-93ad05ee1832#.gk2ch6hz0"
           link_text = "medium.com"
           result =  RenderText.transform(argument)
           expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
           assert String.trim(result) ==  String.trim(expected)
   end


    test "smartLinks parses example 6" do
       argument = "http://www.rsc.org/learn%3C/span%3E-chemistry/resource/res00000466/the-electrolysis-of-solutions"
       link_text = "www.rsc.org"
       result =  RenderText.transform(argument)
       expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
       assert String.trim(result) ==  String.trim(expected)
   end

    test "smartLinks parses example 7" do
      argument = "http://noredink.github.io/json-to-elm/"
      link_text = "noredink.github.io"
      result =  RenderText.transform(argument)
      expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
      assert String.trim(result) ==  String.trim(expected)
  end

   test "userLinks" do
      argument = "https://en.wikipedia.org/wiki/Newton's_laws_of_motion[Newton's Laws]"
      url = "https://en.wikipedia.org/wiki/Newton's_laws_of_motion"
      link_text = "Newton's Laws"
      result =  RenderText.transform(argument)
      expected = "<a href=\"#{url}\" target=\"_blank\">#{link_text}</a>"
      assert result ==  expected

   end

# http://noredink.github.io/json-to-elm/
# ERROR: https://en.wikipedia.org/wiki/Newton's_laws_of_motion[Newton's Laws]

   test "transform parses example in list item" do
     argument = """

- http://noredink.github.io/json-to-elm/

"""
     link_text = "noredink.github.io"
     result = RenderText.transform(argument)
     expected = """
<span style='margin-left:2em; text-indent:-0.7em;display:inline-block;margin-bottom:0.3em;'>-  <a href="http://noredink.github.io/json-to-elm/" target="_blank">noredink.github.io</a></span>
"""

     assert String.trim(result) ==  String.trim(expected)
   end

   test "userLinks parses example 1" do
     url = "https://www.itp.uni-hannover.de/teaching/Open2014/master.pdf"
     link_text = "Quantum Master Equations (Hannover)"
     full_url = url <> "[#{link_text}]"
     result =  RenderText.transform(full_url)
     expected = "<a href=\"#{url}\" target=\"_blank\">#{link_text}</a>"
     assert String.trim(result) ==  String.trim(expected)
   end

   test "userLinks parses example 2" do
     url = "https://www.itp.uni-hannover.de/~weimer/teaching/Open2014/master.pdf"
     link_text = "Quantum Master Equations (Hannover)"
     full_url = url <> "[#{link_text}]"
     result =  RenderText.transform(full_url)
     expected = "<a href=\"#{url}\" target=\"_blank\">#{link_text}</a>"
     assert String.trim(result) ==  String.trim(expected)
   end

   test "formatInlineCode regex" do
         input = "ho ho `foo := bar` ha ha"
         output = RenderText.transform(input)
         expected_output = "ho ho <tt style='color:darkred; font-weight:400'>foo := bar</tt> ha ha"
         assert output == expected_output
   end

   test "apply strikethrough" do
     input = "aaa ~~Call Reza~~ bbb"
     output = RenderText.transform(input)
     IO.puts "OUTPUT: #{output}"
     expected_output="aaa <span style='text-decoration: line-through'>Call Reza</span> bbb"
     assert output == expected_output
   end

   test "apply_markdown regex" do
       input = "ho ho `foo := bar` ha ha"
       output = RenderText.transform(input) |> String.trim
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
   output = RenderText.transform(input)
   expected_output = """
<pre style='margin-bottom:-1.2em;;'>a == b</pre>
foo, bar
<pre style='margin-bottom:-1.2em;;'>c == d</pre>
"""


    assert  output == String.trim(expected_output)
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
<pre style='margin-bottom:-1.2em;;'>a == b</pre>
foo, bar
<pre style='margin-bottom:-1.2em;;'>c == d</pre>
"""
   clean_output = Regex.replace(~r/\s/, output, "")
   clean_expected_utput = Regex.replace(~r/\s/, expected_output, "")

    assert  clean_output == clean_expected_utput
   end


 end
