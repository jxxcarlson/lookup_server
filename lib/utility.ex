defmodule LookupPhoenix.Utility do

  def firstWord(str) do
    String.split(str) |> List.first
  end

end