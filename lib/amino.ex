defmodule Amino do
  defdelegate eval(program), to: Amino.Interpreter
end
