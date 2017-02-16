defmodule RandomListTest do
  use LookupPhoenix.ModelCase
  alias LookupPhoenix.Utility


  test "random integer list with maxint > n" do
    n = 5
    maxint = 10
    output = RandomList.generate_integers(maxint,n)
    Utility.report("RANDOM LIST: ", output)
    assert length(output) == n
  end


  test "random integer list with maxint < n" do
    n = 10
    maxint = 5
    output = RandomList.generate_integers(maxint,n)
    Utility.report("RANDOM LIST: ", output)
    assert length(output) == maxint + 1
  end

end