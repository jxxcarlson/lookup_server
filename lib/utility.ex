defmodule LookupPhoenix.Utility do

  def firstWord(str) do
    String.split(str) |> List.first
  end

  def xForTrue(flag) do
    if flag do
      "X"
    else
     ""
    end
  end

  def add_index_to_maplist(maplist) do
    Enum.reduce(maplist, %{list: [], index: 0}, fn(map, acc) -> %{ list: Map.merge(map, %{idx: acc[:index]}), index: acc[:index]+ 1} end)
  end

end