defmodule AminoInterpreterTest do
  use ExUnit.Case

  alias Amino

  test "swap" do
    assert [2, 3, 5, :swap] |> Amino.eval() == [2, 5, 3]
  end

  test "dup" do
    assert [2, 5, :dup] |> Amino.eval() == [2, 5, 5]
  end

  test "zap" do
    assert [2, 5, :zap] |> Amino.eval() == [2]
  end

  test "unit" do
    assert [2, 5, :unit] |> Amino.eval() == [2, [5]]
  end

  test "cat" do
    assert [[1, 2], [3, 4], :cat] |> Amino.eval() == [[1, 2, 3, 4]]
  end

  test "cons" do
    assert [5, 3, [2], :cons] |> Amino.eval() == [5, [3, 2]]
  end

  test "i" do
    assert [8, 7, [5, 3, [2], :cons], :i] |> Amino.eval() == [8, 7, 5, [3, 2]]
  end

  test "dip" do
    assert [8, 7, [5, 3, [2], :cons], :dip] |> Amino.eval() == [8, 5, [3, 2], 7]
  end

  test "swap == unit dip" do
    assert [2, 3, 5, :swap] |> Amino.eval() == [2, 3, 5, :unit, :dip] |> Amino.eval()
  end

  test "unit == [] cons" do
    assert [2, 5, :unit] |> Amino.eval() == [2, 5, [], :cons] |> Amino.eval()
  end

  test "cons == [unit] dip cat" do
    assert [5, 3, [2], :cons] |> Amino.eval() == [5, 3, [2], [:unit], :dip, :cat] |> Amino.eval()
  end

  test "i == dup dip zap" do
    assert [8, 7, [5, 3, [2], :cons], :i] |> Amino.eval() ==  [8, 7, [5, 3, [2], :cons], :dup, :dip, :zap] |> Amino.eval()
  end

  test "dip == swap unit cat i" do
    assert [8, 7, [5, 3, [2], :cons], :dip] |> Amino.eval() == [8, 7, [5, 3, [2], :cons], :swap, :unit, :cat, :i] |> Amino.eval()
  end

  test "quine - returns own source code as output" do
    assert [[:dup, :cons], :dup, :cons] |> Amino.eval() == [[[:dup, :cons], :dup, :cons]]
  end

  test "Y - combinator" do
    y = [[:dup, :cons], :swap, :cat, :dup, :cons, :i]
    assert [[] | y] |> Amino.eval() == [[[:dup, :cons], :dup, :cons]]
  end
end
