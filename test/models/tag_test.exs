defmodule LookupPhoenix.TagTest do
  use LookupPhoenix.ModelCase

  alias LookupPhoenix.Tag

  @valid_attrs %{content: "some content", title: "some content"}
  @invalid_attrs %{}

  test "all tags are extracted from text" do
    tags = Tag.get_tags("ho ho ho :foo :bar :baz ha ha ha")
    assert tags == [":foo", ":bar", ":baz"]
  end


end
