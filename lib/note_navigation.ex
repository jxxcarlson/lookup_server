defmodule LookupPhoenix.NoteNavigation do

  alias LookupPhoenix.Utility

  @moduledoc """
  NoteNavigation.get(query_string) takes a query string as input
  and produces as output a struct which contains the data needed
  to navigate from one note to another in a set of notes defined by
  the query string.

  The approach of maintaining state in the query string is not a good one.
"""

  def default_navigation_data(id) do
    %{
        first_index: 0,
        index: 0,
        last_index: 0,
        previous_index: 0,
        next_index: 0,
        first_id: id,
        last_id: id,
        previous_id: id,
        current_id: id,
        next_id: id,
        id_string: "#{id}",
        id_list: [id],
        note_count: 1,
        channel: "PUBLIC"
    }
  end

  def get(q_string) do

      IO.puts "QUERY STRING: #{q_string}"
      # Example: q_string=index=4&id_list=35%2C511%2C142%2C525%2C522%2C531%2C233
      query_data = q_string|> Utility.parse_query_string

      # Get inputs
      IO.puts "QUERY DATA[INDEX] = " <> query_data["index"]
      index = query_data["index"]; {index, _} = Integer.parse index
      id_string = query_data["id_string"] |> String.replace("%2C", ",")
      id_list = String.split(id_string, ",")
      channel = query_data["channel"] || "PUBLIC"

     # Compute outputs
      current_id = Enum.at(id_list, index)
      note_count = length(id_list)
      last_index = note_count - 1

      if index >= last_index do
        next_index = 0
      else
        next_index = index + 1
      end
      if index == 0 do
        previous_index = last_index
      else
        previous_index = index - 1
      end

      last_id = Enum.at(id_list, last_index)
      next_id = Enum.at(id_list, next_index)
      previous_id = Enum.at(id_list, previous_index)
      first_id = Enum.at(id_list, 0)

      # Assemble output
      %{
        first_index: 0,
        index: index,
        last_index: last_index,
        previous_index: previous_index,
        next_index: next_index,
        first_id: first_id,
        last_id: last_id,
        previous_id: previous_id,
        current_id: current_id,
        next_id: next_id,
        id_string: id_string,
        id_list: id_list,
        note_count: note_count,
        channel: channel
       }
   end

end