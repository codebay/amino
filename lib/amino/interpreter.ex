defmodule Amino.Interpreter do
  @moduledoc """
  Base combinators ':id', ':swap', ':dup', ':zap', ':unit', ':cat', ':cons', ':i' and ':dip'

        [A] :id   == [A]      The identify function. Does nothing.
    [B] [A] :swap == [A] [B]  Swaps the two programs at the top of the stack.
        [A] :dup  == [A] [A]  Duplicates the program at the top of the stack.
        [A] :unit == [[A]]    Quotes the program at the top of the stack.
    [B] [A] :cat  == [B A]    Concatenates the two programs at the top of the stack.
    [B] [A] :cons == [[B] A]  Inserts the element below the top of the stack as the head of the list on top of the stack.
        [A] :i    == A        Interprets the program at the top of the stack.
    [B] [A] :dip  == A [B]    Pops two programs off the stack, then executes the first and pushes the second.
  """

  defp op(:id, [a | rest]) when is_list(a), do: [a | rest]

  defp op(:swap, [a, b | rest]) when is_list(a) and is_list(b), do: [b, a | rest]

  defp op(:dup, [a | rest]) when is_list(a), do: [a, a | rest]

  defp op(:zap, [a | rest]) when is_list(a), do: rest

  defp op(:unit, [a | rest]) when is_list(a), do: [[a] | rest]

  defp op(:cat, [a, b | rest]) when is_list(a) and is_list(b), do: [b ++ a | rest]

  defp op(:cons, [a, b | rest]) when is_list(a), do: [[b | a] | rest]

  defp op(:i, [a | rest]) when is_list(a), do: dequote(a, rest)

  defp op(:dip, [a, b | rest]) when is_list(a), do: [b | dequote(a, rest)]

  defp op(func, stack) when is_function(func) do
    func.()
    |> dequote(stack)
  end

  defp op(item, stack) do
    [item | stack]
  end

  defp dequote(quotation, stack) when is_list(quotation) and is_list(stack) do
      quotation
      |> Enum.reduce(stack, &op/2)
  end

  def eval(program) when is_list(program) do
    program
    |> dequote([])
    |> Enum.reverse()
  end
end
