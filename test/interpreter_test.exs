defmodule AminoInterpreterTest do
  use ExUnit.Case

  alias Amino

  describe "Combinators" do
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

    # [B] [A] take == [A [B]]
    test "take" do
      assert [ [:B], [:A], :take ] |> Amino.eval() == [ [:A, [:B]] ]
    end
  end

  describe "Base Combinators" do
    # [B] [A] k == A
    test "k" do
      assert [ [:B], [:A], :k ] |> Amino.eval() == [ :A ]
    end

    # [B] [A] cake == [[B] A] [A [B]]
    test "cake" do
      assert [ [:B], [:A], :cake ] |> Amino.eval() == [ [[:B], :A], [:A, [:B]] ]
    end
  end

  describe "Composite Definitions" do
    test "swap == unit dip" do
       assert [ [:B], [:A], :swap ] |> Amino.eval() == [ [:B], [:A], :unit, :dip ] |> Amino.eval()
    end

    test "unit == [] cons" do
      assert [ [:A], :unit ] |> Amino.eval() == [ [:A], [], :cons] |> Amino.eval()
    end

    test "cons == [unit] dip cat" do
      assert [ [:B], [:A], :cons ] |> Amino.eval() == [ [:B], [:A], [:unit], :dip, :cat] |> Amino.eval()
    end

    test "i == dup dip zap" do
      assert [ [:A], :i ] |> Amino.eval() ==  [ [:A], :dup, :dip, :zap] |> Amino.eval()
    end

    test "dip == swap unit cat i" do
      assert [ [:B], [:A], :dip ] |> Amino.eval() == [ [:B], [:A], :swap, :unit, :cat, :i] |> Amino.eval()
    end

    test "dip == take i" do
      assert [ [:B], [:A], :dip ] |> Amino.eval() ==  [ [:B], [:A], :take, :i] |> Amino.eval()
    end

    test "zap == [] k" do
      assert [ [:A], :zap ] |> Amino.eval() ==  [ [:A], [], :k] |> Amino.eval()
    end

    test "dip == cake k" do
      assert [ [:B], [:A], :dip] |> Amino.eval() == [ [:B], [:A], :cake, :k] |> Amino.eval()
    end

    test "cons == cake [] k" do
      assert [ [:B], [:A], :cons ] |> Amino.eval() == assert [ [:B], [:A], :cake, [], :k ] |> Amino.eval()
    end

    test "i == [[]] dip k" do
      assert [ [:A], :i ] |> Amino.eval() == assert [ [:A], [[]], :dip, :k ] |> Amino.eval()
    end

    test "dup == [] cake dip dip" do
      assert [ [:A], :dup ] |> Amino.eval() == assert [ [:A], [], :cake, :dip, :dip ] |> Amino.eval()
    end
  end

  # [true option] [false option] [condition] if
  describe "Conditional" do
    test "if True" do
      if_ = fn -> [:i] end
      true_ = fn -> [[:zap, :i]] end

      assert [ [:True], [:False], true_, if_ ] |> Amino.eval() == [ :True ]
    end

    test "if False" do
      if_ = fn -> [:i] end
      false_ = fn -> [[:swap, :zap, :i]] end

      assert [ [:True], [:False], false_, if_ ] |> Amino.eval() == [ :False ]
    end
  end

  describe "Useful Combined Combinators" do
    test "Y - combinator" do
      y = fn -> [[:dup, :cons], :swap, :cat, :dup, :cons, :i] end

      assert [ [], y ] |> Amino.eval() == [ [[:dup, :cons], :dup, :cons] ]
    end

    # [C] [B] [A] dig2 == [B] [A] [C]
    test "dig2" do
      dig2 = fn -> [[], :cons, :cons, :dip] end

      assert [ [:C], [:B], [:A], dig2 ] |> Amino.eval() == [ [:B], [:A], [:C] ]
    end

    # [C] [B] [A] bury2 == [A] [C] [B]
    test "bury2" do
      bury2 = fn -> [[[], :cons, :cons], :dip, :swap, :i] end

      assert [ [:C], [:B], [:A], bury2 ] |> Amino.eval() == [ [:A], [:C], [:B] ]
    end
  end
end
