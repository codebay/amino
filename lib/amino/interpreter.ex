defmodule Amino.Interpreter do
  @moduledoc """
  Base combinators swap', 'dup', 'zap', 'unit', 'cat', 'cons', 'i' and 'dip'
  """

  def term(:swap, [a, b | rest] = _stack), do: [b, a | rest]

  def term(:dup, [a | rest] = _stack), do: [a, a | rest]

  def term(:zap, [_a | rest] = _stack), do: rest

  def term(:unit, [a | rest] = _stack), do: [[a] | rest]

  def term(:cat, [a, b | rest] = _stack) when is_list(a) and is_list(b), do: [b ++ a | rest]

  def term(:cons, [a, b | rest] = _stack) when is_list(a), do: [[b | a] | rest]

  def term(:i, [a | rest] = _stack) when is_list(a), do: dequote(a, rest)

  def term(:dip, [a, b | rest] = _stack) when is_list(a), do: [b | dequote(a, rest)]

  def term(item, stack), do: [item | stack]

  def dequote(quotation, stack) when is_list(quotation) and is_list(stack) do
      quotation
      |> Enum.reduce(stack, &term/2)
  end

  def eval(program) when is_list(program) do
    program
    |> Enum.reduce([], &term/2)
    |> Enum.reverse()
  end
end
