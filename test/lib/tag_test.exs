defmodule RenderTextTest do
  use LookupPhoenix.ModelCase
  alias LookupPhoenix.Tag
  alias LookupPhoenix.Note

  test "content2taglist" do
       input = %Note{content: "This is a test. :foo :bar hohoho"}
       output = Tag.content2taglist(input)
       assert output == ["foo", "bar"]
    end

end
