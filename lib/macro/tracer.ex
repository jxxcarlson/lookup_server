# Source: http://theerlangelist.com/article/macros_1

defmodule Tracer do
  defmacro trace(expression_ast) do
    string_representation = Macro.to_string(expression_ast)

    quote do
      result = unquote(expression_ast)
      Tracer.print(unquote(string_representation), result)
      result
    end
  end

  def print(string_representation, result) do
    IO.puts "Result of #{string_representation}: #{inspect result}"
  end

  defmacro inspect2(label, code) do
      IO.puts label
      IO.inspect code
      quote do
        result = unquote(code)
        IO.inspect result
      end
    end

   defmacro sort_by_field(query, field ) do
     quote do
       from item in query,
          order_by: [asc: item.unquote(field)]
     end
   end


end