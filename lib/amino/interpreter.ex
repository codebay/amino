defmodule Amino.Interpreter do
  @moduledoc """
  Base combinators swap', 'dup', 'zap', 'unit', 'cat', 'cons', 'i' and 'dip'
  """

  def swap([a, b | rest]), do: [b, a | rest]

  def dup([a | rest]), do: [a, a | rest]

  def zap([_a | rest]), do: rest

  def unit([a | rest]), do: [[a] | rest]

  def cat([a, b | rest]) when is_list(a) and is_list(b), do: [b ++ a | rest]

  def cons([a, b | rest]) when is_list(a), do: [[b | a] | rest]

  def i([a | rest]) when is_list(a), do: dequote(a, rest)

  def dip([a, b | rest]) when is_list(a), do: [b | dequote(a, rest)]

  defp dequote(quotation, stack) when is_list(quotation) and is_list(stack) do
      quotation
      |> Enum.reduce(stack, &term/2)
  end

  defp term(function, stack) when is_atom(function) do
    Kernel.apply(__MODULE__, function, [stack])
  end

  defp term(item, stack) do
    [item | stack]
  end

  def eval(program) when is_list(program) do
    program
    |> dequote([])
    |> Enum.reverse()
  end
end
