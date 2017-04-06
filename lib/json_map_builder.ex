defmodule LookupPhoenix.JSONMapBuilder do

#  def to_map(list) when is_list(list) and length(list) > 0 do
#    case list |> List.first do
#      {_, _} ->
#        Enum.reduce(list, %{}, fn(tuple, acc) ->
#          {key, value} = tuple
#          Map.put(acc, binary_to_atom(key), to_map(value))
#        end)
#      _ ->
#        list
#    end
#  end
#
#  def to_map(tuple) when is_tuple(tuple) do
#    {key, value} = tuple
#    Enum.into([{binary_to_atom(key), to_map(value)}], %{})
#  end
#
#  def to_map(value), do: value

end