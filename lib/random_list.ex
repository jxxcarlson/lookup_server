defmodule RandomList do
  # import Random
  # https://elixirforum.com/t/random-based-on-rand-not-random/1518


   # the first element is head, the tail is the rest of the list
   # count must be greater than 0 to match
   def split([head | tail], count) when count > 0 do

     # recursively call passing in tail and decrementing the count
     # it will match a two element tuple
     {left, right} = split(tail, count-1)

     # return a two element tuple containing
     # the head, concatenated with the left element
     # and the right (i.e. the rest of the list)
     {[head | left], right}

   end

   # this is for when count is <= 0
   # return a two element tuple with an empty array the rest of the list
   # do not recurse
   def split(list, _count), do: {[], list}

    def truncateAt(list, n) do
      {a, b} = split(list, n)
      a
    end

    def cut(list, n) do
      {a, b} = split(list, n)
      b ++ a
    end

    def random_split(list) do
      n = :rand.uniform(length(list)-1)
      split(list,n)
    end

    def random_cut(list) do
      {a,b} = random_split(list)
      b ++ a
    end

    def mcut(list) do
      n = length(list)
      c1 = div(n,2)
      c2 = div(n,3)
      c3 = div(n,4)
      list
      |> random_cut
      |> cut(c1)
      |> random_cut
      |> cut(c2)
      |> random_cut
      |> cut(c3)
    end

    def proj1(x) do
      elem(x,0)
    end

    def mmcut(list, n)
      when length(list) <= n, do: list

    def mmcut(list, n)
      when length(list) > n, do: mcut(list)
        |> split(n)
        |> proj1

    # insert element in list if (a) it is not already
    # in the list, and (b) the list is not yet full,
    # i.e., has n elements.
    #
    # Thus the goal is to produce a list of n unique
    # elments.
    def unique_insert(list, element, n) do
      if Enum.member?(list, element) or length(list) >= n do
        list
      else
        [element|list]
      end
    end

    def generate_integers(max_int, n)  do
      # n = min(max_int, n)
      # state = Random.seed(:exsplus)
      Enum.reduce(1..(n + 10), [], fn(_k, output) -> unique_insert(output, :rand.uniform(max_int + 1) - 1, n) end)

    end


end