defmodule Amino do
  defdelegate eval(program), to: Amino.Interpreter

  def primer() do
    [ [[[:dup, :cons], :dup, :cons]] ]
  end

  def soup() do
    %{
      swap: 1000,
      dup: 1000,
      zap: 1000,
      unit: 1000,
      cat: 1000,
      cons: 1000,
      i: 1000,
      dip: 1000
    }
  end

  def generation(progs, soup) do
    Enum.reduce(progs, {progs, soup}, fn parent, {children, soup} ->
      try do
        child = eval(parent)
        residue = consume(child, soup)

        if Enum.filter(residue, fn {_k,v} -> v < 0 end) == [] do
          {[child | children], residue}
        else
          {children, soup}
        end
      rescue
        _e in RuntimeError -> {children, soup}
      end
    end)
  end

  def consume(prog, soup) do
    prog
    |> List.flatten()
    |> Enum.reduce(soup, &Map.update(&2, &1, 0, fn x -> x-1 end))
  end
end
