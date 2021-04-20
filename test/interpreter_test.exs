defmodule AminoInterpreterTest do
  use ExUnit.Case

  alias Amino

  # [A] :id   == [A]
  test "id" do
    assert [ [:A], :id ] |> Amino.eval() == [ [:A] ]
  end

  # [B] [A] swap == [A] [B]
  test "swap" do
    assert [ [:B], [:A], :swap ] |> Amino.eval() == [ [:A], [:B] ]
  end

  # [A] dup == [A] [A]
  test "dup" do
    assert [ [:A], :dup ] |> Amino.eval() == [ [:A], [:A] ]
  end

  # [A] zap ==
  test "zap" do
    assert [ [:A], :zap ] |> Amino.eval() == [ ]
  end

  # [A] unit == [[A]]
  test "unit" do
    assert [ [:A], :unit ] |> Amino.eval() == [ [[:A]] ]
  end

  # [B] [A] cat == [B A]
  test "cat" do
    assert [ [:B], [:A], :cat ] |> Amino.eval() == [ [:B, :A] ]
  end

  # [B] [A] cons == [[B] A]
  test "cons" do
    assert [ [:B], [:A], :cons ] |> Amino.eval() == [ [[:B], :A] ]
  end

  # [A] i == A
  test "i" do
    assert [ [:A], :i ] |> Amino.eval() == [ :A ]
  end

  # [B] [A] :dip  == A [B]
  test "dip" do
    assert [ [:B], [:A], :dip] |> Amino.eval() == [ :A, [:B] ]
  end

  # test "swap == unit dip" do
  #   assert [2, 3, 5, :swap] |> Amino.eval() == [2, 3, 5, :unit, :dip] |> Amino.eval()
  # end

  # test "unit == [] cons" do
  #   assert [2, 5, :unit] |> Amino.eval() == [2, 5, [], :cons] |> Amino.eval()
  # end

  # test "cons == [unit] dip cat" do
  #   assert [5, 3, [2], :cons] |> Amino.eval() == [5, 3, [2], [:unit], :dip, :cat] |> Amino.eval()
  # end

  # test "i == dup dip zap" do
  #   assert [8, 7, [5, 3, [2], :cons], :i] |> Amino.eval() ==  [8, 7, [5, 3, [2], :cons], :dup, :dip, :zap] |> Amino.eval()
  # end

  # test "dip == swap unit cat i" do
  #   assert [8, 7, [5, 3, [2], :cons], :dip] |> Amino.eval() == [8, 7, [5, 3, [2], :cons], :swap, :unit, :cat, :i] |> Amino.eval()
  # end

  # test "quine - returns own source code as output" do
  #   assert [[:dup, :cons], :dup, :cons] |> Amino.eval() == [[[:dup, :cons], :dup, :cons]]
  # end

  # test "Y - combinator" do
  #   y = fn -> [[:dup, :cons], :swap, :cat, :dup, :cons, :i] end
  #   assert [[], y] |> Amino.eval() == [[[:dup, :cons], :dup, :cons]]
  # end

  # test "if True then 'This is the true option' else 'This is the false option'" do
  #   # [true option] [false option] [condition] if
  #   if_ = fn -> [:i] end
  #   true_ = fn -> [[:zap, :i]] end
  #   assert [["This is the true option"], ["This is the false option"], true_, if_] |> Amino.eval() == ["This is the true option"]
  # end

  # test "if False then 'This is the true option' else 'This is the false option'" do
  #   # [true option] [false option] [condition] if
  #   if_ = fn -> [:i] end
  #   false_ = fn -> [[:swap, :zap, :i]] end
  #   assert [["This is the true option"], ["This is the false option"], false_, if_] |> Amino.eval() == ["This is the false option"]
  # end
end
