defmodule LookupPhoenix.NoteNavigation do

  alias LookupPhoenix.Utility

  @moduledoc """
  NoteNavigation.get(query_string, id) takes a query string as input
  and produces as output a struct which contains the data needed
  to navigate from one note to another in a set of notes defined by
  the query string.

  The approach of maintaining state in the query string is not a good one.
"""

  require IEx

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

  def s2i(n) do
    if is_number(n) do
       n
    else
       String.to_integer(n)
    end
  end

  def get(id_list, id) do

      id_list = (id_list || [id])

      Utility.report("1. id_list", id_list)
      Utility.report("1. id", id)

      id = s2i(id)
      id_list = id_list |> Enum.map(fn(item) -> s2i(item) end)

      # IEx.pry

      Utility.report("2. id_list", id_list)
      Utility.report("2. id", id)

      index = Enum.find_index(id_list, fn(x) -> x == id end)


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
        id_string: "IDX",
        id_list: id_list,
        note_count: note_count,
        channel: "XC"
       }
   end

end