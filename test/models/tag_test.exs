defmodule LookupPhoenix.TagTest do
  use LookupPhoenix.ModelCase

  alias LookupPhoenix.Tag

  @valid_attrs %{content: "some content", title: "some content"}
  @invalid_attrs %{}

  test "all tags are extracted from text" do
    tags = Tag.get_tags("ho ho ho :foo :bar :baz ha ha ha")
    assert tags == [":foo", ":bar", ":baz"]
  end

  test "put_element adds a new key with value 1 if that key is not present in the map" do
    map1 = %{"foo" => 1, "bar" =>4}
    map2 = Tag.put_element("yada", map1)
    assert map2["yada"] == 1
  end

  test "put_element increments the value of a key if that key equals the inserted element" do
      map1 = %{"foo" => 1, "bar" =>4}
      map2 = Tag.put_element("foo", map1)
      assert map2["foo"] == 2
  end

  test "merge_elements_into_map " do
      map = %{}
      elements = ["foo", "bar", "foo", "baz", "bar", "foo", "foo"]
      map2 = Tag.merge_elements_into_map(elements, map)
      assert map2["foo"] == 4
      assert map2["bar"] == 2
      assert map2["baz"] == 1
  end

  test "make tag map of user notes" do
        map = %{}
        elements = ["foo", "bar", "foo", "baz", "bar", "foo", "foo"]
        map2 = Tag.merge_elements_into_map(elements, map)
        assert map2["foo"] == 4
        assert map2["bar"] == 2
        assert map2["baz"] == 1
   end

end
