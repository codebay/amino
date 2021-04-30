defmodule AminoInterpreterTest do
  use ExUnit.Case

  alias Amino

  describe "Combinators" do
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
  end

  describe "Composite Definitions - from swap, dup, zap, unit, cat, cons, i, dip" do
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
  end

  # [true option] [false option] [condition] if
  describe "Church Booleans" do
    test "if " do
      true_ = fn -> [ [:zap, :i] ] end
      false_ = fn -> [ [:swap, :zap, :i] ] end
      if_ = fn -> [ :i ] end

      assert [ [:A], [:B], true_, if_ ] |> Amino.eval() == [ :A ]
      assert [ [:A], [:B], false_, if_ ] |> Amino.eval() == [ :B ]
    end

    test "alternative if - with conditional at the bottom of the stack" do
      true_ = fn -> [ [:zap, :i] ] end
      false_ = fn -> [ [:swap, :zap, :i] ] end
      branch_ = fn -> [ :unit, :cons, :swap, :cat, :i ] end

      assert [ true_, [:A], [:B], branch_ ] |> Amino.eval() == [ :A ]
      assert [ false_, [:A], [:B], branch_ ] |> Amino.eval() == [ :B ]
    end

    test "Logical NOT" do
      true_ = fn -> [ [:zap, :i] ] end
      false_ = fn -> [ [:swap, :zap, :i] ] end
      branch_ = fn -> [ :unit, :cons, :swap, :cat, :i ] end
      not_ = fn -> [ [false_], [true_], branch_ ] end

      assert [ false_, not_ ] |> Amino.eval() == [ true_ ] |> Amino.eval()
      assert [ true_,  not_ ] |> Amino.eval() == [ false_ ] |> Amino.eval()
    end

    test "Logical OR" do
      true_ = fn -> [ [:zap, :i] ] end
      false_ = fn -> [ [:swap, :zap, :i] ] end
      branch_ = fn -> [ :unit, :cons, :swap, :cat, :i ] end
      or_ = fn -> [ [:zap, true_], [], branch_ ] end

      assert [ false_, false_, or_ ] |> Amino.eval() == [ false_ ] |> Amino.eval()
      assert [ false_, true_,  or_ ] |> Amino.eval() == [ true_ ] |> Amino.eval()
      assert [ true_,  false_, or_ ] |> Amino.eval() == [ true_ ] |> Amino.eval()
      assert [ true_,  true_,  or_ ] |> Amino.eval() == [ true_ ] |> Amino.eval()
    end

    test "Logical AND" do
      true_ = fn -> [ [:zap, :i] ] end
      false_ = fn -> [ [:swap, :zap, :i] ] end
      branch_ = fn -> [ :unit, :cons, :swap, :cat, :i ] end
      and_ = fn -> [ [], [:zap, false_], branch_ ] end

      assert [ false_, false_, and_ ] |> Amino.eval() == [ false_ ] |> Amino.eval()
      assert [ false_, true_,  and_ ] |> Amino.eval() == [ false_ ] |> Amino.eval()
      assert [ true_,  false_, and_ ] |> Amino.eval() == [ false_ ] |> Amino.eval()
      assert [ true_,  true_,  and_ ] |> Amino.eval() == [ true_ ] |> Amino.eval()
    end

    test "Logical XOR" do
      true_ = fn -> [ [:zap, :i] ] end
      false_ = fn -> [ [:swap, :zap, :i] ] end
      branch_ = fn -> [ :unit, :cons, :swap, :cat, :i ] end
      not_ = fn -> [ [false_], [true_], branch_ ] end
      xor_ = fn -> [ [not_], [], branch_ ] end

      assert [ false_, false_, xor_ ] |> Amino.eval() == [ false_ ] |> Amino.eval()
      assert [ false_, true_,  xor_ ] |> Amino.eval() == [ true_ ] |> Amino.eval()
      assert [ true_,  false_, xor_ ] |> Amino.eval() == [ true_ ] |> Amino.eval()
      assert [ true_,  true_,  xor_ ] |> Amino.eval() == [ false_ ] |> Amino.eval()
    end
  end

  describe "Church Numericals" do
    test "Numbers" do
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ [c0], cSucc ] end;
      c2 = fn -> [ [c1], cSucc ] end;
      c3 = fn -> [ [c2], cSucc ] end;

      assert [ [:A], c0 ] |> Amino.eval() == []
      assert [ [:A], c1 ] |> Amino.eval() == [:A]
      assert [ [:A], c2 ] |> Amino.eval() == [:A, :A]
      assert [ [:A], c3 ] |> Amino.eval() == [:A, :A, :A]
    end

    test "Add" do
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end
      cAdd = fn -> [ [[[cSucc], :cons]], :dip, :i, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ [c0], cSucc ] end;
      c2 = fn -> [ [c1], cSucc ] end;
      c3 = fn -> [ [c2], cSucc ] end;
      c4 = fn -> [ [c3], cSucc ] end;
      c5 = fn -> [ [c4], cSucc ] end;

      assert [ [c1], [c4], cAdd ] |> Amino.eval() == [ c5 ] |> Amino.eval()
      assert [ [c2], [c3], cAdd ] |> Amino.eval() == [ c5 ] |> Amino.eval()
    end
  end

  describe "Alternative Church Numericals" do
    test "repn - take program and run n times" do
      run = fn -> [ :dup, :dip ] end

      rep0 = fn -> [ :zap ] end
      rep1 = fn -> [ run, :zap ] end
      rep2 = fn -> [ run, run, :zap ] end
      rep3 = fn -> [ run, run, run, :zap ] end

      assert [ [:A], rep0  ] |> Amino.eval() == []
      assert [ [:A], rep1  ] |> Amino.eval() == [:A]
      assert [ [:A], rep2  ] |> Amino.eval() == [:A, :A]
      assert [ [:A], rep3  ] |> Amino.eval() == [:A, :A, :A]
    end
  end

  describe "Useful Combined Combinators" do
    test "Y - combinator" do
      y = fn -> [[:dup, :cons], :swap, :cat, :dup, :cons, :i] end

      assert [ [], y ] |> Amino.eval() == [ [[:dup, :cons], :dup, :cons] ]
    end
  end
end
