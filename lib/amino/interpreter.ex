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

  Boolean Logic
            :true  => [:zap, :i]
            :false => [:swap :zap :i]

            :not => [:false] [:true]

   [:false] :not =>
  """

  # Combinator Operators

  defp op(:swap, [a, b | rest]), do: [b, a | rest]

  defp op(:dup, [a | rest]), do: [a, a | rest]

  defp op(:zap, [_a | rest]), do: rest

  defp op(:unit, [a | rest]), do: [[a] | rest]

  defp op(:cat, [a, b | rest]) when is_list(a) and is_list(b), do: [b ++ a | rest]

  defp op(:cons, [a, b | rest]) when is_list(a), do: [[b | a] | rest]

  defp op(:i, [a | rest]) when is_list(a), do: dequote(a, rest)

  defp op(:dip, [a, b | rest]) when is_list(a) and is_list(b), do: [b | dequote(a, rest)]

  defp op(func, stack) when is_function(func) do
    case Function.info(func, :arity) do
      {:arity, 0} -> dequote(func.(), stack)
      {:arity, 1} -> func.(stack)
      _ -> stack
    end
  end

  defp op(item, stack), do: [item | stack]

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
