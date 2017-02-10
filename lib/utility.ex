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
     Enum.reduce(maplist, %{list: [], index: 0}, fn(map, acc) -> %{ list: acc.list ++ [%{data: map, index: acc.index}], index: acc.index + 1} end).list
     |> Enum.map(fn(pair) -> Map.merge(pair.data, %{index: pair.index}) end)
  end

  def parse_query_string(str) do
    str
    |> String.split("&")
    |> Enum.map(fn(item) -> String.split(item, "=") end )
    |> Enum.reduce(%{}, fn(item, acc) -> Map.merge(acc, %{List.first(item) => List.last(item)}) end )
  end

end