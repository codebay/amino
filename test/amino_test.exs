defmodule AminoTest do
  use ExUnit.Case

  alias Amino

  test "population" do

    ops = %{
      1 => [],
      2 => :swap,
      3 => :dup,
      4 => :zap,
      5 => :unit,
      6 => :cat,
      7 => :cons
    }

    data = [["A"], ["G"], ["T"], ["U"], ["A"], ["T"]]

    nops = Enum.count(ops)

    code =
      Enum.map(1..:rand.uniform(50), fn _x -> ops[:rand.uniform(nops)] end)
      |> Enum.chunk_while([],
        fn x, acc ->
          if :rand.uniform(5) == 1 do
            {:cont, [x | acc], []}
          else
            {:cont, [x | acc]}
          end
        end,
        fn
          [] -> {:cont, []}
          acc -> {:cont, acc, []}
        end
      )
      |> Enum.reduce([], fn x, acc ->
         if acc == [] do
           x
         else
           if :rand.uniform(3) == 1 do
              x ++ acc
           else
              [x | acc]
           end
         end
      end)

    data ++ code
    |> IO.inspect(label: "prog")
    |> Amino.eval()
    |> IO.inspect(label: "eval")
  end
end
