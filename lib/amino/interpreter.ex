defmodule Amino.Interpreter do
  @moduledoc """
        [A] is a quotation containing one or more combinators

  Base combinators

        [A] :id   == [A]      The identify function. Does nothing.
    [B] [A] :swap == [A] [B]  Swaps the two quotations at the top of the stack.
        [A] :dup  == [A] [A]  Duplicates the quotation at the top of the stack.
        [A] :zap  ==          Zap the quotation at the top of the stack.
        [A] :unit == [[A]]    Quotes the quotation at the top of the stack.
    [B] [A] :cat  == [B A]    Concatenates the two quotations at the top of the stack.
    [B] [A] :cons == [[B] A]  Inserts the element below the top of the stack as the head of the list on top of the stack.
        [A] :i    == A        Interprets the quotation at the top of the stack.
    [B] [A] :dip  == A [B]    Pops two quotations off the stack, then executes the first and pushes the second.

  Additional combinators

    [B] [A] :take == [A [B]]  Takes the quotation at the end of the stack

  Minimial Base using just two combinators

    [B] [A] :k    == A
    [B] [A] :cake == [[B] A] [A [B]]

  Boolean Logic
            :true  => [:zap, :i]
            :false => [:swap :zap :i]

            :not => [:false] [:true]

   [:false] :not =>
  """

  # Combinator Operators

  defp op(:id, [a | rest]) when is_list(a), do: [a | rest]

  defp op(:swap, [a, b | rest]) when is_list(a) and is_list(b), do: [b, a | rest]

  defp op(:dup, [a | rest]) when is_list(a), do: [a, a | rest]

  defp op(:zap, [a | rest]) when is_list(a), do: rest

  defp op(:unit, [a | rest]) when is_list(a), do: [[a] | rest]

  defp op(:cat, [a, b | rest]) when is_list(a) and is_list(b), do: [b ++ a | rest]

  defp op(:cons, [a, b | rest]) when is_list(a) and is_list(b), do: [[b | a] | rest]

  defp op(:i, [a | rest]) when is_list(a), do: dequote(a, rest)

  defp op(:dip, [a, b | rest]) when is_list(a) and is_list(b), do: [b | dequote(a, rest)]

  defp op(:take, [a, b | rest]) when is_list(a) and is_list(b), do: [a ++ [b] | rest]

  # List Operators

  defp op(:map, [a, b | rest]) when is_list(a) and is_list(b) do
    [List.flatten(Enum.map(b, &(dequote([&1|a], [])))) | rest]
  end

  defp op(:reverse, [a | rest]) when is_list(a), do: [Enum.reverse(a) | rest]

  # Boolean & Conditional Operators

  defp op(:if, [a, b, c | rest]) when is_boolean(a) and is_list(b) and is_list(c), do:
    [if a do c else b end | rest]

  # String Operators

  defp op(:reverse, [a | rest]) when is_binary(a), do: [String.reverse(a) | rest]

  defp op(:replace, [a, b, c | rest]) when is_binary(a) and is_binary(b), do: [String.replace(c, b, a) | rest]

  defp op(:concat, [a, b | rest]) when is_binary(a) and is_binary(b), do: [b <> a | rest]

  # Numerical Operators

  defp op(:+, [a, b | rest]) when is_number(a) and is_number(b), do: [b+a | rest]

  defp op(:-, [a, b | rest]) when is_number(a) and is_number(b), do: [b-a | rest]

  defp op(:*, [a, b | rest]) when is_number(a) and is_number(b), do: [b*a | rest]

  defp op(:/, [a, b | rest]) when is_number(a) and is_number(b), do: [if a != 0 do b/a else 0 end | rest]

  defp op(:%, [a, b | rest]) when is_integer(a) and is_integer(b), do: [Integer.mod(b, a) | rest]

  defp op(func, stack) when is_function(func) do
    func.()
    |> dequote(stack)
  end

  defp op(item, stack) when is_list(item) or is_boolean(item) or is_number(item) or is_binary(item) do
    [item | stack]
  end

  defp op(_item, stack) do
    stack
  end

  defp dequote(quotation, stack) do
      quotation
      |> Enum.reduce(stack, &op/2)
  end

  def eval(quotation) when is_list(quotation) do
    quotation
    |> dequote([])
    |> Enum.reverse()
  end
end
