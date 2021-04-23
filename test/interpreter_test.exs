defmodule AminoInterpreterTest do
  use ExUnit.Case

  alias Amino

  describe "Combinators" do
    # [A] :id   == [A]
    test "id" do
      assert [ ["A"], :id ] |> Amino.eval() == [ ["A"] ]
    end

    # [B] [A] swap == [A] [B]
    test "swap" do
      assert [ ["B"], ["A"], :swap ] |> Amino.eval() == [ ["A"], ["B"] ]
    end

    # [A] dup == [A] [A]
    test "dup" do
      assert [ ["A"], :dup ] |> Amino.eval() == [ ["A"], ["A"] ]
    end

    # [A] zap ==
    test "zap" do
      assert [ ["A"], :zap ] |> Amino.eval() == [ ]
    end

    # [A] unit == [[A]]
    test "unit" do
      assert [ ["A"], :unit ] |> Amino.eval() == [ [["A"]] ]
    end

    # [B] [A] cat == [B A]
    test "cat" do
      assert [ ["B"], ["A"], :cat ] |> Amino.eval() == [ ["B", "A"] ]
    end

    # [B] [A] cons == [[B] A]
    test "cons" do
      assert [ ["B"], ["A"], :cons ] |> Amino.eval() == [ [["B"], "A"] ]
    end

    # [A] i == A
    test "i" do
      assert [ ["A"], :i ] |> Amino.eval() == [ "A" ]
    end

    # [B] [A] :dip  == A [B]
    test "dip" do
      assert [ ["B"], ["A"], :dip] |> Amino.eval() == [ "A", ["B"] ]
    end

    # [B] [A] take == [A [B]]
    test "take" do
      assert [ ["B"], ["A"], :take ] |> Amino.eval() == [ ["A", ["B"]] ]
    end
  end

  describe "Composite Definitions - from swap, dup, zap, unit, cat, cons, i, dip" do
    test "swap == unit dip" do
       assert [ ["B"], ["A"], :swap ] |> Amino.eval() == [ ["B"], ["A"], :unit, :dip ] |> Amino.eval()
    end

    test "unit == [] cons" do
      assert [ ["A"], :unit ] |> Amino.eval() == [ ["A"], [], :cons] |> Amino.eval()
    end

    test "cons == [unit] dip cat" do
      assert [ ["B"], ["A"], :cons ] |> Amino.eval() == [ ["B"], ["A"], [:unit], :dip, :cat] |> Amino.eval()
    end

    test "i == dup dip zap" do
      assert [ ["A"], :i ] |> Amino.eval() ==  [ ["A"], :dup, :dip, :zap] |> Amino.eval()
    end

    test "dip == swap unit cat i" do
      assert [ ["B"], ["A"], :dip ] |> Amino.eval() == [ ["B"], ["A"], :swap, :unit, :cat, :i] |> Amino.eval()
    end

    test "dip == take i" do
      assert [ ["B"], ["A"], :dip ] |> Amino.eval() ==  [ ["B"], ["A"], :take, :i] |> Amino.eval()
    end
  end

  # [true option] [false option] [condition] if
  describe "Conditional" do
    test "if True" do
      assert [ ["If Option"], ["Else Option"], true, :if ] |> Amino.eval() == [ ["If Option"] ]
    end

    test "if False" do
      assert [ ["If Option"], ["Else Option"], false, :if ] |> Amino.eval() == [ ["Else Option"] ]
    end
  end

  describe "List Operators" do
    test "Map" do
      assert [ [1, 2, 3], [4, :+], :map ] |> Amino.eval() == [ [ 5, 6, 7 ] ]
    end

    test "Reverse" do
      assert [ [1, 2, 3], :reverse ] |> Amino.eval() == [ [3, 2, 1] ]
    end
  end

  describe "String Operators" do
    test "reverse" do
      assert [ "abcd", :reverse ] |> Amino.eval() == [ "dcba" ]
    end

    test "replace" do
      assert [ "a,b,c", ",", "-", :replace ] |> Amino.eval() == [ "a-b-c" ]
    end

    test "concat" do
      assert [ "Hello", "World", :concat ] |> Amino.eval() == [ "HelloWorld" ]
    end
  end

  describe "Numeric Operators" do
    test "plus" do
      assert [ 2, 3, :+ ] |> Amino.eval() == [ 5 ]
    end

    test "minus" do
      assert [ 5, 2, :- ] |> Amino.eval() == [ 3 ]
    end

    test "multiplication" do
      assert [ 2, 3, :* ] |> Amino.eval() == [ 6 ]
    end

    test "division" do
      assert [ 6, 2, :/ ] |> Amino.eval() == [ 3 ]
    end

    test "modulo" do
      assert [ 5, 2, :% ] |> Amino.eval() == [ 1 ]
    end
  end

  describe "Useful Combined Combinators" do
    test "Elixir function" do
      translate = fn [head | rest] ->
        value =
          case head do
            1 -> "one"
            2 -> "two"
            _ -> "none"
          end

        [value | rest]
      end

      assert [ 2, translate ] |> Amino.eval() == [ "two" ]
    end

    test "Y - combinator" do
      y = fn -> [[:dup, :cons], :swap, :cat, :dup, :cons, :i] end

      assert [ [], y ] |> Amino.eval() == [ [[:dup, :cons], :dup, :cons] ]
    end
  end
end
