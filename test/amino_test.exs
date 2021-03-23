defmodule AminoBaseTest do
  use ExUnit.Case

  alias Amino

  test "swap" do
    assert [2, 3, 5, :swap] |> Amino.exec() == [2, 5, 3]
  end

  test "dup" do
    assert [2, 5, :dup] |> Amino.exec() == [2, 5, 5]
  end

  test "zap" do
    assert [2, 5, :zap] |> Amino.exec() == [2]
  end

  test "unit" do
    assert [2, 5, :unit] |> Amino.exec() == [2, [5]]
  end

  test "cat" do
    assert [[1, 2], [3, 4], :cat] |> Amino.exec() == [[1, 2, 3, 4]]
  end

  test "cons" do
    assert [5, 3, [2], :cons] |> Amino.exec() == [5, [3, 2]]
  end

  test "i" do
    assert [8, 7, [5, 3, [2], :cons], :i] |> Amino.exec() == [8, 7, 5, [3, 2]]
  end

  test "dip" do
    assert [8, 7, [5, 3, [2], :cons], :dip] |> Amino.exec() == [8, 5, [3, 2], 7]
  end

  test "swap == unit dip" do
    assert [2, 3, 5, :swap] |> Amino.exec() == [2, 3, 5, :unit, :dip] |> Amino.exec()
  end

  test "unit == [] cons" do
    assert [2, 5, :unit] |> Amino.exec() == [2, 5, [], :cons] |> Amino.exec()
  end

  test "cons == [unit] dip cat" do
    assert [5, 3, [2], :cons] |> Amino.exec() == [5, 3, [2], [:unit], :dip, :cat] |> Amino.exec()
  end

  test "i == dup dip zap" do
    assert [8, 7, [5, 3, [2], :cons], :i] |> Amino.exec() ==  [8, 7, [5, 3, [2], :cons], :dup, :dip, :zap] |> Amino.exec()
  end

  test "dip == swap unit cat i" do
    assert [8, 7, [5, 3, [2], :cons], :dip] |> Amino.exec() == [8, 7, [5, 3, [2], :cons], :swap, :unit, :cat, :i] |> Amino.exec()
  end

  test "quine - returns own source code as output" do
    assert [[:dup, :cons], :dup, :cons] |> Amino.exec() == [[[:dup, :cons], :dup, :cons]]
  end

  test "Y - combinator" do
    y = [[:dup, :cons], :swap, :cat, :dup, :cons, :i]
    assert [[] | y] |> Amino.exec() == [[[:dup, :cons], :dup, :cons]]
  end
end
