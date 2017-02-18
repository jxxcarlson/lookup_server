defmodule LookupPhoenix.Utility do

  def report(message, object) do
    IO.puts "========================"
    IO.puts message
    IO.inspect object
    IO.puts "========================"
  end

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

  def str2map(str) do
    parts = String.split(str,"=")
    if length(parts) == 2 do
      [key, value] = parts
      %{key => value}
    else
      %{"foo" => "bar"}
    end

  end

  def qs2map(string) do
    string
    |> String.split( "&")
    |> Enum.reduce(%{}, fn(item, acc) -> Map.merge(acc, str2map(item)) end)
  end

  def map22list(m) do
    Map.keys(m) |> Enum.map( fn(key) -> [key, m[key]] end)
  end

  def sort2list(list, direction) do
    case direction do
      "desc" -> list |> Enum.sort(fn(e1, e2) -> hd(tl(e1)) > hd(tl(e2)) end)
       _ -> list |> Enum.sort(fn(e1, e2) -> hd(tl(e1)) <= hd(tl(e2)) end)
    end
  end

  def proj1_2list(list) do
    Enum.map(list, fn(element) -> hd(element) end)
  end

  def proj2_2list(list) do
    Enum.map(list, fn(element) -> hd(tl(element)) end)
  end

end