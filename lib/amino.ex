defmodule Amino do
  def exec(program) when is_list(program) do
    program
    |> Amino.Interpreter.eval()
  end
end
