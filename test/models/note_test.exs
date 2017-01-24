defmodule LookupPhoenix.NoteTest do
  use LookupPhoenix.ModelCase

  alias LookupPhoenix.Note

  @valid_attrs %{content: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Note.changeset(%Note{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Note.changeset(%Note{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "smartLinks parses example 1" do
     argument = "https://stripe.com"
     link_text = "stripe.com"
     result =  Note.makeSmartLinks(argument)
     expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
     assert String.trim(result) ==  String.trim(expected)
  end

  test "smartLinks parses example 2" do
      argument = "https://stripe.com/"
      link_text = "stripe.com"
      result =  Note.makeSmartLinks(argument)
      expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
      assert String.trim(result) ==  String.trim(expected)
  end

  test "smartLinks parses example 3" do
      argument = "https://stripe.com/a/b/c"
      link_text = "stripe.com"
      result =  Note.makeSmartLinks(argument)
      expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
      assert String.trim(result) ==  String.trim(expected)
  end

   test "smartLinks parses example 4" do
        argument = "https://stripe.com?foo=bar"
        link_text = "stripe.com"
        result =  Note.makeSmartLinks(argument)
        expected = "<a href=\"#{argument}\" target=\"_blank\">#{link_text}</a>"
        assert String.trim(result) ==  String.trim(expected)
   end

   test "formatInlineCode regex" do
         input = "ho ho `foo := bar` ha ha"
         output = Note.formatInlineCode(input)
         expected_output = "ho ho <tt style='color:darkred; font-weight:400'>foo := bar</tt> ha ha"
         assert output == expected_output
   end

   test "apply_markdown regex" do
       input = "ho ho `foo := bar` ha ha"
       output = Note.apply_markdown(input)
       expected_output = "ho ho <tt style='color:darkred; font-weight:400'>foo := bar</tt> ha ha"
       assert output == expected_output
   end

   test "transform_text regex" do
        input = "ho ho `foo := bar` ha ha"
        output = Note.transform_text(input)
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
   output = Note.formatCode(input)
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

test "transform_text" do
input = """

----
a == b
----
foo, bar
----
c == d
----

"""
   output = Note.transform_text(input)
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
     output = Note.getURLs(input)
     expected_output = ["http://foo.io", "http://bar.io?yada=yada"]
     assert output == expected_output
   end

   test "prep urls" do
     input = "abc http://foo.io def http://bar.io?yada=yada"
     output = Note.getURLs(input) |> Note.prepURLs
     expected_output = [["http://foo.io", "http://foo.io"], ["http://bar.io?yada=yada", "http://bar.io"]]
     assert output == expected_output
   end

   test "simplify one url" do
      input = "abc http://foo.io?a=b def http://bar.io?yada=yada ho ho ho"
      substitution_list = Note.getURLs(input) |> Note.prepURLs
      substitution_item = hd(substitution_list)
      output = Note.simplify_one_URL(substitution_item, input)
      expected_output = "abc http://foo.io def http://bar.io?yada=yada ho ho ho"
      assert output == expected_output
   end

   test "simplify urls" do
      input = "abc http://foo.io def http://bar.io?yada=yada ho ho ho"
      output = Note.simplifyURLs(input)
      expected_output = "abc http://foo.io def http://bar.io ho ho ho"
      assert output == expected_output
   end



end
