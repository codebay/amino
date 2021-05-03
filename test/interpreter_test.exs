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

  describe "Church Numerals" do
    test "Numbers - succ (n+1)" do
      succ = fn -> [ [:dup, :dip], :dip, :i ] end # n + 1

      c0 = fn -> [ :zap ] end
      c1 = fn -> [ [c0], succ ] end
      c2 = fn -> [ [c1], succ ] end
      c3 = fn -> [ [c2], succ ] end

      assert [ [:A], c0 ] |> Amino.eval() == []
      assert [ [:A], c1 ] |> Amino.eval() == [:A]
      assert [ [:A], c2 ] |> Amino.eval() == [:A, :A]
      assert [ [:A], c3 ] |> Amino.eval() == [:A, :A, :A]
    end

    test "Add" do
      succ = fn -> [ [:dup, :dip], :dip, :i ] end
      add = fn -> [ [[[succ], :cons]], :dip, :i, :i ] end

      c0 = fn -> [ :zap ] end
      c1 = fn -> [ [c0], succ ] end
      c2 = fn -> [ [c1], succ ] end
      c3 = fn -> [ [c2], succ ] end
      c4 = fn -> [ [c3], succ ] end
      c5 = fn -> [ [c4], succ ] end

      assert [ [c0], [c0], add ] |> Amino.eval() == [ c0 ] |> Amino.eval()
      assert [ [c0], [c5], add ] |> Amino.eval() == [ c5 ] |> Amino.eval()
      assert [ [c1], [c4], add ] |> Amino.eval() == [ c5 ] |> Amino.eval()
      assert [ [c2], [c3], add ] |> Amino.eval() == [ c5 ] |> Amino.eval()
    end

    test "Multiplication" do
      succ = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ [c0], succ ] end
      c2 = fn -> [ [c1], succ ] end
      c3 = fn -> [ [c2], succ ] end
      c4 = fn -> [ [c3], succ ] end
      c5 = fn -> [ [c4], succ ] end
      c6 = fn -> [ [c5], succ ] end

      add = fn -> [ [[[succ], :cons]], :dip, :i, :i ] end
      mul = fn -> [ [[[c0]], :dip, [add], :cons, [:cons], :cons ], :dip, :i, :i ] end

      assert [ [c1], [c1], mul ] |> Amino.eval() == [ c1 ] |> Amino.eval()
      assert [ [c1], [c4], mul ] |> Amino.eval() == [ c4 ] |> Amino.eval()
      assert [ [c2], [c3], mul ] |> Amino.eval() == [ c6 ] |> Amino.eval()
    end

    test "Power" do
      succ = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ [c0], succ ] end
      c2 = fn -> [ [c1], succ ] end
      c3 = fn -> [ [c2], succ ] end
      c4 = fn -> [ [c3], succ ] end
      c5 = fn -> [ [c4], succ ] end
      c6 = fn -> [ [c5], succ ] end
      c7 = fn -> [ [c6], succ ] end
      c8 = fn -> [ [c7], succ ] end

      add = fn -> [ [[[succ], :cons]], :dip, :i, :i ] end
      mul = fn -> [ [[[c0]], :dip, [add], :cons, [:cons], :cons ], :dip, :i, :i ] end
      pow = fn -> [ [[[c1]], :dip, [mul], :cons, [:cons], :cons ], :dip, :i, :i ] end

      assert [ [c2], [c0], pow ] |> Amino.eval() == [ c1 ] |> Amino.eval()
      assert [ [c2], [c1], pow ] |> Amino.eval() == [ c2 ] |> Amino.eval()
      assert [ [c2], [c2], pow ] |> Amino.eval() == [ c4 ] |> Amino.eval()
      assert [ [c2], [c3], pow ] |> Amino.eval() == [ c8 ] |> Amino.eval()
    end

    test "Combinations of add, mul & pow" do
      succ = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ [c0], succ ] end
      c2 = fn -> [ [c1], succ ] end
      c3 = fn -> [ [c2], succ ] end
      c4 = fn -> [ [c3], succ ] end
      c5 = fn -> [ [c4], succ ] end
      c6 = fn -> [ [c5], succ ] end
      c7 = fn -> [ [c6], succ ] end
      c8 = fn -> [ [c7], succ ] end

      add = fn -> [ [[[succ], :cons]], :dip, :i, :i ] end
      mul = fn -> [ [[[c0]], :dip, [add], :cons, [:cons], :cons ], :dip, :i, :i ] end
      pow = fn -> [ [[[c1]], :dip, [mul], :cons, [:cons], :cons ], :dip, :i, :i ] end

      # 2^2 * (1+1) = 4 * 2 = 8
      # notice that quotations are need around the expression, similiar to parentheses in infix notation!
      # This occurs because the add, mul & pow combinators result in unquoted results.
      assert [ [[c2], [c2], pow], [[c1], [c1], add], mul ] |> Amino.eval() == [ c8 ] |> Amino.eval()
    end
  end

  describe "Alternative Church Numerals" do
    test "Numbers - succ (n+1)" do
      # runs the program p n times i.e [p] Rn == p p ... p [p]
      run = fn -> [ :dup, :dip ] end

      c0 = fn -> [ :zap ] end
      c1 = fn -> [ run, c0 ] end
      c2 = fn -> [ run, c1 ] end
      c3 = fn -> [ run, c2 ] end

      assert [ [:A], c0  ] |> Amino.eval() == []
      assert [ [:A], c1  ] |> Amino.eval() == [:A]
      assert [ [:A], c2  ] |> Amino.eval() == [:A, :A]
      assert [ [:A], c3  ] |> Amino.eval() == [:A, :A, :A]
    end

    test "Add" do
      run = fn -> [ :dup, :dip ] end
      succ = fn -> [ [:dup, :dip], :dip, :i ] end
      add = fn -> [ [[[succ], :cons]], :dip, :i, :i ] end

      c0 = fn -> [ :zap ] end
      c1 = fn -> [ run, c0 ] end
      c2 = fn -> [ run, c1 ] end
      c3 = fn -> [ run, c2 ] end
      c4 = fn -> [ run, c3 ] end
      c5 = fn -> [ run, c4 ] end

      assert [ [c0], [c0], add ] |> Amino.eval() == [ c0 ] |> Amino.eval()
      assert [ [c0], [c5], add ] |> Amino.eval() == [ c5 ] |> Amino.eval()
      assert [ [c1], [c4], add ] |> Amino.eval() == [ c5 ] |> Amino.eval()
      assert [ [c2], [c3], add ] |> Amino.eval() == [ c5 ] |> Amino.eval()
    end

    test "Multiplication" do
      run = fn -> [ :dup, :dip ] end
      succ = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ run, c0 ] end
      c2 = fn -> [ run, c1 ] end
      c3 = fn -> [ run, c2 ] end
      c4 = fn -> [ run, c3 ] end
      c5 = fn -> [ run, c4 ] end
      c6 = fn -> [ run, c5 ] end

      add = fn -> [ [[[succ], :cons]], :dip, :i, :i ] end
      mul = fn -> [ [[[c0]], :dip, [add], :cons, [:cons], :cons ], :dip, :i, :i ] end

      assert [ [c1], [c1], mul ] |> Amino.eval() == [ c1 ] |> Amino.eval()
      assert [ [c1], [c4], mul ] |> Amino.eval() == [ c4 ] |> Amino.eval()
      assert [ [c2], [c3], mul ] |> Amino.eval() == [ c6 ] |> Amino.eval()
    end

    test "Power" do
      run = fn -> [ :dup, :dip ] end
      succ = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ run, c0 ] end
      c2 = fn -> [ run, c1 ] end
      c3 = fn -> [ run, c2 ] end
      c4 = fn -> [ run, c3 ] end
      c5 = fn -> [ run, c4 ] end
      c6 = fn -> [ run, c5 ] end
      c7 = fn -> [ run, c6 ] end
      c8 = fn -> [ run, c7 ] end

      add = fn -> [ [[[succ], :cons]], :dip, :i, :i ] end
      mul = fn -> [ [[[c0]], :dip, [add], :cons, [:cons], :cons ], :dip, :i, :i ] end
      pow = fn -> [ [[[c1]], :dip, [mul], :cons, [:cons], :cons ], :dip, :i, :i ] end

      assert [ [c2], [c0], pow ] |> Amino.eval() == [ c1 ] |> Amino.eval()
      assert [ [c2], [c1], pow ] |> Amino.eval() == [ c2 ] |> Amino.eval()
      assert [ [c2], [c2], pow ] |> Amino.eval() == [ c4 ] |> Amino.eval()
      assert [ [c2], [c3], pow ] |> Amino.eval() == [ c8 ] |> Amino.eval()
    end

    test "Combinations of add, mul & pow" do
      run = fn -> [ :dup, :dip ] end
      succ = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ run, c0 ] end
      c2 = fn -> [ run, c1 ] end
      c3 = fn -> [ run, c2 ] end
      c4 = fn -> [ run, c3 ] end
      c5 = fn -> [ run, c4 ] end
      c6 = fn -> [ run, c5 ] end
      c7 = fn -> [ run, c6 ] end
      c8 = fn -> [ run, c7 ] end

      add = fn -> [ [[[succ], :cons]], :dip, :i, :i ] end
      mul = fn -> [ [[[c0]], :dip, [add], :cons, [:cons], :cons ], :dip, :i, :i ] end
      pow = fn -> [ [[[c1]], :dip, [mul], :cons, [:cons], :cons ], :dip, :i, :i ] end

      # 2^2 * (1+1) = 4 * 2 = 8
      # notice that quotations are need around the expression, similiar to parentheses in infix notation!
      # This occurs because the add, mul & pow combinators result in unquoted results.
      assert [ [[c2], [c2], pow], [[c1], [c1], add], mul ] |> Amino.eval() == [ c8 ] |> Amino.eval()
    end
  end

  describe "Third Alternative Church Numerals" do
    test "Numbers - succ (n+1)" do
      succ = fn -> [ [[:dup, :dip], :dip, :i], :cons ] end

      q0 = fn -> [ [:zap] ] end
      q1 = fn -> [ q0, succ ] end
      q2 = fn -> [ q1, succ ] end
      q3 = fn -> [ q2, succ ] end

      assert [ [:A], q0, :i ] |> Amino.eval() == []
      assert [ [:A], q1, :i ] |> Amino.eval() == [:A]
      assert [ [:A], q2, :i ] |> Amino.eval() == [:A, :A]
      assert [ [:A], q3, :i ] |> Amino.eval() == [:A, :A, :A]
    end

    test "Add" do
      succ = fn -> [ [[:dup, :dip], :dip, :i], :cons ] end

      q0 = fn -> [ [:zap] ] end
      q1 = fn -> [ q0, succ ] end
      q2 = fn -> [ q1, succ ] end
      q3 = fn -> [ q2, succ ] end
      q4 = fn -> [ q3, succ ] end
      q5 = fn -> [ q4, succ ] end

      add = fn -> [ [[[succ, :i], :cons], :swap, :i, :i], :cons, :cons ] end

      assert [ q0, q0, add, :i ] |> Amino.eval() == [ q0, :i ] |> Amino.eval()
      assert [ q0, q5, add, :i ] |> Amino.eval() == [ q5, :i ] |> Amino.eval()
      assert [ q1, q4, add, :i ] |> Amino.eval() == [ q5, :i ] |> Amino.eval()
      assert [ q2, q3, add, :i ] |> Amino.eval() == [ q5, :i ] |> Amino.eval()
    end

    test "Multiplication" do
      succ = fn -> [ [[:dup, :dip], :dip, :i], :cons ] end

      q0 = fn -> [ [:zap] ] end
      q1 = fn -> [ q0, succ ] end
      q2 = fn -> [ q1, succ ] end
      q3 = fn -> [ q2, succ ] end
      q4 = fn -> [ q3, succ ] end
      q5 = fn -> [ q4, succ ] end
      q6 = fn -> [ q5, succ ] end

      add = fn -> [ [[[succ, :i], :cons], :swap, :i, :i], :cons, :cons ] end
      mul = fn -> [ [[[[q0, :i]], :dip, [add, :i], :cons, [:cons], :cons], :dip, :i, :i], :cons, :cons ] end

      assert [ q1, q1, mul, :i ] |> Amino.eval() == [ q1, :i ] |> Amino.eval()
      assert [ q1, q4, mul, :i ] |> Amino.eval() == [ q4, :i ] |> Amino.eval()
      assert [ q2, q3, mul, :i ] |> Amino.eval() == [ q6, :i ] |> Amino.eval()
    end

    test "Power" do
      succ = fn -> [ [[:dup, :dip], :dip, :i], :cons ] end

      q0 = fn -> [ [:zap] ] end
      q1 = fn -> [ q0, succ ] end
      q2 = fn -> [ q1, succ ] end
      q3 = fn -> [ q2, succ ] end
      q4 = fn -> [ q3, succ ] end
      q5 = fn -> [ q4, succ ] end
      q6 = fn -> [ q5, succ ] end
      q7 = fn -> [ q6, succ ] end
      q8 = fn -> [ q7, succ ] end

      add = fn -> [ [[[succ, :i], :cons], :swap, :i, :i], :cons, :cons ] end
      mul = fn -> [ [[[[q0, :i]], :dip, [add, :i], :cons, [:cons], :cons], :dip, :i, :i], :cons, :cons ] end
      pow = fn -> [ [[[[q1, :i]], :dip, [mul, :i], :cons, [:cons], :cons], :dip, :i, :i], :cons, :cons ] end

      assert [ q2, q0, pow, :i ] |> Amino.eval() == [ q1, :i ] |> Amino.eval()
      assert [ q2, q1, pow, :i ] |> Amino.eval() == [ q2, :i ] |> Amino.eval()
      assert [ q2, q2, pow, :i ] |> Amino.eval() == [ q4, :i ] |> Amino.eval()
      assert [ q2, q3, pow, :i ] |> Amino.eval() == [ q8, :i ] |> Amino.eval()
    end

    test "Combinations of add, mul & pow" do
      succ = fn -> [ [[:dup, :dip], :dip, :i], :cons ] end

      q0 = fn -> [ [:zap] ] end
      q1 = fn -> [ q0, succ ] end
      q2 = fn -> [ q1, succ ] end
      q3 = fn -> [ q2, succ ] end
      q4 = fn -> [ q3, succ ] end
      q5 = fn -> [ q4, succ ] end
      q6 = fn -> [ q5, succ ] end
      q7 = fn -> [ q6, succ ] end
      q8 = fn -> [ q7, succ ] end

      add = fn -> [ [[[succ, :i], :cons], :swap, :i, :i], :cons, :cons ] end
      mul = fn -> [ [[[[q0, :i]], :dip, [add, :i], :cons, [:cons], :cons], :dip, :i, :i], :cons, :cons ] end
      pow = fn -> [ [[[[q1, :i]], :dip, [mul, :i], :cons, [:cons], :cons], :dip, :i, :i], :cons, :cons ] end

      # 2^2 * (1+1) = 4 * 2 = 8
      assert [ q2, q2, pow, q1, q1, add, mul, :i ] |> Amino.eval() == [ q8, :i ] |> Amino.eval()
    end
  end

  describe "Church predicates & conditionals" do
    test "if equal to zero" do
      true_ = fn -> [ [:zap, :i] ] end
      false_ = fn -> [ [:swap, :zap, :i] ] end
      eq0 = fn -> [ [[true_], [:zap, [false_]]], :dip, :i, :i ] end
      if_ = fn -> [ :i ] end

      run = fn -> [ :dup, :dip ] end

      c0 = fn -> [ :zap ] end
      c1 = fn -> [ run, c0 ] end
      c2 = fn -> [ run, c1 ] end

      assert [ [:Yes], [:No], [c0], eq0, if_ ] |> Amino.eval() == [ :Yes ]
      assert [ [:Yes], [:No], [c1], eq0, if_ ] |> Amino.eval() == [ :No ]
      assert [ [:Yes], [:No], [c2], eq0, if_ ] |> Amino.eval() == [ :No ]
    end
  end

  describe "Useful Combined Combinators" do
    test "Y - combinator" do
      y = fn -> [[:dup, :cons], :swap, :cat, :dup, :cons, :i] end

      assert [ [], y ] |> Amino.eval() == [ [[:dup, :cons], :dup, :cons] ]
    end
  end
end
