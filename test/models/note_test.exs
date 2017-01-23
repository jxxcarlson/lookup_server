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

end
