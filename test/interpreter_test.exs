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
    test "Numbers" do
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end
      c1 = fn -> [ [c0], cSucc ] end
      c2 = fn -> [ [c1], cSucc ] end
      c3 = fn -> [ [c2], cSucc ] end

      assert [ [:A], c0 ] |> Amino.eval() == []
      assert [ [:A], c1 ] |> Amino.eval() == [:A]
      assert [ [:A], c2 ] |> Amino.eval() == [:A, :A]
      assert [ [:A], c3 ] |> Amino.eval() == [:A, :A, :A]
    end

    test "Add" do
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end
      cAdd = fn -> [ [[[cSucc], :cons]], :dip, :i, :i ] end

      c0 = fn -> [ :zap ] end
      c1 = fn -> [ [c0], cSucc ] end
      c2 = fn -> [ [c1], cSucc ] end
      c3 = fn -> [ [c2], cSucc ] end
      c4 = fn -> [ [c3], cSucc ] end
      c5 = fn -> [ [c4], cSucc ] end

      assert [ [c0], [c0], cAdd ] |> Amino.eval() == [ c0 ] |> Amino.eval()
      assert [ [c0], [c5], cAdd ] |> Amino.eval() == [ c5 ] |> Amino.eval()
      assert [ [c1], [c4], cAdd ] |> Amino.eval() == [ c5 ] |> Amino.eval()
      assert [ [c2], [c3], cAdd ] |> Amino.eval() == [ c5 ] |> Amino.eval()
    end

    test "Multiplication" do
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ [c0], cSucc ] end
      c2 = fn -> [ [c1], cSucc ] end
      c3 = fn -> [ [c2], cSucc ] end
      c4 = fn -> [ [c3], cSucc ] end
      c5 = fn -> [ [c4], cSucc ] end
      c6 = fn -> [ [c5], cSucc ] end

      cAdd = fn -> [ [[[cSucc], :cons]], :dip, :i, :i ] end
      cMul = fn -> [ [[[c0]], :dip, [cAdd], :cons, [:cons], :cons ], :dip, :i, :i ] end

      assert [ [c1], [c1], cMul ] |> Amino.eval() == [ c1 ] |> Amino.eval()
      assert [ [c1], [c4], cMul ] |> Amino.eval() == [ c4 ] |> Amino.eval()
      assert [ [c2], [c3], cMul ] |> Amino.eval() == [ c6 ] |> Amino.eval()
    end

    test "Power" do
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ [c0], cSucc ] end
      c2 = fn -> [ [c1], cSucc ] end
      c3 = fn -> [ [c2], cSucc ] end
      c4 = fn -> [ [c3], cSucc ] end
      c5 = fn -> [ [c4], cSucc ] end
      c6 = fn -> [ [c5], cSucc ] end
      c7 = fn -> [ [c6], cSucc ] end
      c8 = fn -> [ [c7], cSucc ] end

      cAdd = fn -> [ [[[cSucc], :cons]], :dip, :i, :i ] end
      cMul = fn -> [ [[[c0]], :dip, [cAdd], :cons, [:cons], :cons ], :dip, :i, :i ] end
      cPow = fn -> [ [[[c1]], :dip, [cMul], :cons, [:cons], :cons ], :dip, :i, :i ] end

      assert [ [c2], [c0], cPow ] |> Amino.eval() == [ c1 ] |> Amino.eval()
      assert [ [c2], [c1], cPow ] |> Amino.eval() == [ c2 ] |> Amino.eval()
      assert [ [c2], [c2], cPow ] |> Amino.eval() == [ c4 ] |> Amino.eval()
      assert [ [c2], [c3], cPow ] |> Amino.eval() == [ c8 ] |> Amino.eval()
    end

    test "Combinations of add, mul & pow" do
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ [c0], cSucc ] end
      c2 = fn -> [ [c1], cSucc ] end
      c3 = fn -> [ [c2], cSucc ] end
      c4 = fn -> [ [c3], cSucc ] end
      c5 = fn -> [ [c4], cSucc ] end
      c6 = fn -> [ [c5], cSucc ] end
      c7 = fn -> [ [c6], cSucc ] end
      c8 = fn -> [ [c7], cSucc ] end

      cAdd = fn -> [ [[[cSucc], :cons]], :dip, :i, :i ] end
      cMul = fn -> [ [[[c0]], :dip, [cAdd], :cons, [:cons], :cons ], :dip, :i, :i ] end
      cPow = fn -> [ [[[c1]], :dip, [cMul], :cons, [:cons], :cons ], :dip, :i, :i ] end

      # 2^2 * (1+1) = 4 * 2 = 8
      # notice that quotations are need around the expression, similiar to parentheses in infix notation!
      # This occurs because the cAdd, cMul & cPow combinators result in unquoted results.
      assert [ [[c2], [c2], cPow], [[c1], [c1], cAdd], cMul ] |> Amino.eval() == [ c8 ] |> Amino.eval()
    end
  end

  describe "Alternative Church Numerals" do
    test "Numbers" do
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
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end
      cAdd = fn -> [ [[[cSucc], :cons]], :dip, :i, :i ] end

      c0 = fn -> [ :zap ] end
      c1 = fn -> [ run, c0 ] end
      c2 = fn -> [ run, c1 ] end
      c3 = fn -> [ run, c2 ] end
      c4 = fn -> [ run, c3 ] end
      c5 = fn -> [ run, c4 ] end

      assert [ [c0], [c0], cAdd ] |> Amino.eval() == [ c0 ] |> Amino.eval()
      assert [ [c0], [c5], cAdd ] |> Amino.eval() == [ c5 ] |> Amino.eval()
      assert [ [c1], [c4], cAdd ] |> Amino.eval() == [ c5 ] |> Amino.eval()
      assert [ [c2], [c3], cAdd ] |> Amino.eval() == [ c5 ] |> Amino.eval()
    end

    test "Multiplication" do
      run = fn -> [ :dup, :dip ] end
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ run, c0 ] end
      c2 = fn -> [ run, c1 ] end
      c3 = fn -> [ run, c2 ] end
      c4 = fn -> [ run, c3 ] end
      c5 = fn -> [ run, c4 ] end
      c6 = fn -> [ run, c5 ] end

      cAdd = fn -> [ [[[cSucc], :cons]], :dip, :i, :i ] end
      cMul = fn -> [ [[[c0]], :dip, [cAdd], :cons, [:cons], :cons ], :dip, :i, :i ] end

      assert [ [c1], [c1], cMul ] |> Amino.eval() == [ c1 ] |> Amino.eval()
      assert [ [c1], [c4], cMul ] |> Amino.eval() == [ c4 ] |> Amino.eval()
      assert [ [c2], [c3], cMul ] |> Amino.eval() == [ c6 ] |> Amino.eval()
    end

    test "Power" do
      run = fn -> [ :dup, :dip ] end
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ run, c0 ] end
      c2 = fn -> [ run, c1 ] end
      c3 = fn -> [ run, c2 ] end
      c4 = fn -> [ run, c3 ] end
      c5 = fn -> [ run, c4 ] end
      c6 = fn -> [ run, c5 ] end
      c7 = fn -> [ run, c6 ] end
      c8 = fn -> [ run, c7 ] end

      cAdd = fn -> [ [[[cSucc], :cons]], :dip, :i, :i ] end
      cMul = fn -> [ [[[c0]], :dip, [cAdd], :cons, [:cons], :cons ], :dip, :i, :i ] end
      cPow = fn -> [ [[[c1]], :dip, [cMul], :cons, [:cons], :cons ], :dip, :i, :i ] end

      assert [ [c2], [c0], cPow ] |> Amino.eval() == [ c1 ] |> Amino.eval()
      assert [ [c2], [c1], cPow ] |> Amino.eval() == [ c2 ] |> Amino.eval()
      assert [ [c2], [c2], cPow ] |> Amino.eval() == [ c4 ] |> Amino.eval()
      assert [ [c2], [c3], cPow ] |> Amino.eval() == [ c8 ] |> Amino.eval()
    end

    test "Combinations of add, mul & pow" do
      run = fn -> [ :dup, :dip ] end
      cSucc = fn -> [ [:dup, :dip], :dip, :i ] end

      c0 = fn -> [ :zap ] end;
      c1 = fn -> [ run, c0 ] end
      c2 = fn -> [ run, c1 ] end
      c3 = fn -> [ run, c2 ] end
      c4 = fn -> [ run, c3 ] end
      c5 = fn -> [ run, c4 ] end
      c6 = fn -> [ run, c5 ] end
      c7 = fn -> [ run, c6 ] end
      c8 = fn -> [ run, c7 ] end

      cAdd = fn -> [ [[[cSucc], :cons]], :dip, :i, :i ] end
      cMul = fn -> [ [[[c0]], :dip, [cAdd], :cons, [:cons], :cons ], :dip, :i, :i ] end
      cPow = fn -> [ [[[c1]], :dip, [cMul], :cons, [:cons], :cons ], :dip, :i, :i ] end

      # 2^2 * (1+1) = 4 * 2 = 8
      # notice that quotations are need around the expression, similiar to parentheses in infix notation!
      # This occurs because the cAdd, cMul & cPow combinators result in unquoted results.
      assert [ [[c2], [c2], cPow], [[c1], [c1], cAdd], cMul ] |> Amino.eval() == [ c8 ] |> Amino.eval()
    end
  end

  describe "Third Alternative Church Numerals" do
    test "Numbers" do
      qSucc = fn -> [ [[:dup, [:i], :dip], :dip, :i], :cons ] end

      q0 = fn -> [ [:zap] ] end
      q1 = fn -> [ q0, qSucc ] end
      q2 = fn -> [ q1, qSucc ] end
      q3 = fn -> [ q2, qSucc ] end

      assert [ [:A], q0, :i ] |> Amino.eval() == []
      assert [ [:A], q1, :i ] |> Amino.eval() == [:A]
      assert [ [:A], q2, :i ] |> Amino.eval() == [:A, :A]
      assert [ [:A], q3, :i ] |> Amino.eval() == [:A, :A, :A]
    end

    test "Add" do
      qSucc = fn -> [ [[:dup, [:i], :dip], :dip, :i], :cons ] end

      q0 = fn -> [ [:zap] ] end
      q1 = fn -> [ q0, qSucc ] end
      q2 = fn -> [ q1, qSucc ] end
      q3 = fn -> [ q2, qSucc ] end
      q4 = fn -> [ q3, qSucc ] end
      q5 = fn -> [ q4, qSucc ] end

      qAdd = fn -> [ [[[qSucc, :i], :cons], :swap, :i, :i], :cons, :cons ] end

      assert [ q0, q0, qAdd, :i ] |> Amino.eval() == [ q0, :i ] |> Amino.eval()
      assert [ q0, q5, qAdd, :i ] |> Amino.eval() == [ q5, :i ] |> Amino.eval()
      assert [ q1, q4, qAdd, :i ] |> Amino.eval() == [ q5, :i ] |> Amino.eval()
      assert [ q2, q3, qAdd, :i ] |> Amino.eval() == [ q5, :i ] |> Amino.eval()
    end

    test "Multiplication" do
      qSucc = fn -> [ [[:dup, [:i], :dip], :dip, :i], :cons ] end

      q0 = fn -> [ [:zap] ] end
      q1 = fn -> [ q0, qSucc ] end
      q2 = fn -> [ q1, qSucc ] end
      q3 = fn -> [ q2, qSucc ] end
      q4 = fn -> [ q3, qSucc ] end
      q5 = fn -> [ q4, qSucc ] end
      q6 = fn -> [ q5, qSucc ] end

      qAdd = fn -> [ [[[qSucc, :i], :cons], :swap, :i, :i], :cons, :cons ] end
      qMul = fn -> [ [[[[q0, :i]], :dip, [qAdd, :i], :cons, [:cons], :cons], :dip, :i, :i], :cons, :cons ] end

      assert [ q1, q1, qMul, :i ] |> Amino.eval() == [ q1, :i ] |> Amino.eval()
      assert [ q1, q4, qMul, :i ] |> Amino.eval() == [ q4, :i ] |> Amino.eval()
      assert [ q2, q3, qMul, :i ] |> Amino.eval() == [ q6, :i ] |> Amino.eval()
    end

    test "Power" do
      qSucc = fn -> [ [[:dup, [:i], :dip], :dip, :i], :cons ] end

      q0 = fn -> [ [:zap] ] end
      q1 = fn -> [ q0, qSucc ] end
      q2 = fn -> [ q1, qSucc ] end
      q3 = fn -> [ q2, qSucc ] end
      q4 = fn -> [ q3, qSucc ] end
      q5 = fn -> [ q4, qSucc ] end
      q6 = fn -> [ q5, qSucc ] end
      q7 = fn -> [ q6, qSucc ] end
      q8 = fn -> [ q7, qSucc ] end

      qAdd = fn -> [ [[[qSucc, :i], :cons], :swap, :i, :i], :cons, :cons ] end
      qMul = fn -> [ [[[[q0, :i]], :dip, [qAdd, :i], :cons, [:cons], :cons], :dip, :i, :i], :cons, :cons ] end
      qPow = fn -> [ [[[[q1, :i]], :dip, [qMul, :i], :cons, [:cons], :cons], :dip, :i, :i], :cons, :cons ] end

      assert [ q2, q0, qPow, :i ] |> Amino.eval() == [ q1, :i ] |> Amino.eval()
      assert [ q2, q1, qPow, :i ] |> Amino.eval() == [ q2, :i ] |> Amino.eval()
      assert [ q2, q2, qPow, :i ] |> Amino.eval() == [ q4, :i ] |> Amino.eval()
      assert [ q2, q3, qPow, :i ] |> Amino.eval() == [ q8, :i ] |> Amino.eval()
    end

    test "Combinations of add, mul & pow" do
      qSucc = fn -> [ [[:dup, [:i], :dip], :dip, :i], :cons ] end

      q0 = fn -> [ [:zap] ] end
      q1 = fn -> [ q0, qSucc ] end
      q2 = fn -> [ q1, qSucc ] end
      q3 = fn -> [ q2, qSucc ] end
      q4 = fn -> [ q3, qSucc ] end
      q5 = fn -> [ q4, qSucc ] end
      q6 = fn -> [ q5, qSucc ] end
      q7 = fn -> [ q6, qSucc ] end
      q8 = fn -> [ q7, qSucc ] end

      qAdd = fn -> [ [[[qSucc, :i], :cons], :swap, :i, :i], :cons, :cons ] end
      qMul = fn -> [ [[[[q0, :i]], :dip, [qAdd, :i], :cons, [:cons], :cons], :dip, :i, :i], :cons, :cons ] end
      qPow = fn -> [ [[[[q1, :i]], :dip, [qMul, :i], :cons, [:cons], :cons], :dip, :i, :i], :cons, :cons ] end

      # 2^2 * (1+1) = 4 * 2 = 8
      assert [ q2, q2, qPow, q1, q1, qAdd, qMul, :i ] |> Amino.eval() == [ q8, :i ] |> Amino.eval()
    end
  end

  describe "Useful Combined Combinators" do
    test "Y - combinator" do
      y = fn -> [[:dup, :cons], :swap, :cat, :dup, :cons, :i] end

      assert [ [], y ] |> Amino.eval() == [ [[:dup, :cons], :dup, :cons] ]
    end
  end
end
