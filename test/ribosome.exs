defmodule AminoRibosomeTest do
  use ExUnit.Case

  alias Amino

  test "ribosome" do

    translate = fn [head | rest] when is_binary(head) ->
      value =
        case head do
          "uuu" -> "phe"
          "ucu" -> "ser"
          "uau" -> "tyr"
          "ugu" -> "cys"
          "uuc" -> "phe"
          "ucc" -> "ser"
          "uac" -> "tyr"
          "ugc" -> "cys"
          "uua" -> "leu"
          "uca" -> "ser"
          "uaa" -> [] # stop codon
          "uga" -> [] # stop codon
          "uug" -> "leu"
          "ucg" -> "ser"
          "uag" -> [] # stop codon
          "ugg" -> "trp"
          "cuu" -> "leu"
          "ccu" -> "pro"
          "cau" -> "his"
          "cgu" -> "arg"
          "cuc" -> "leu"
          "ccc" -> "pro"
          "cac" -> "his"
          "cgc" -> "arg"
          "cua" -> "leu"
          "cca" -> "pro"
          "caa" -> "gln"
          "cga" -> "arg"
          "cug" -> "leu"
          "ccg" -> "pro"
          "cag" -> "gln"
          "cgg" -> "arg"
          "auu" -> "ile"
          "acu" -> "thr"
          "aau" -> "asn"
          "agu" -> "ser"
          "auc" -> "ile"
          "acc" -> "thr"
          "aac" -> "asn"
          "agc" -> "ser"
          "aua" -> "ile"
          "aca" -> "thr"
          "aaa" -> "lys"
          "aga" -> "arg"
          "aug" -> "met"
          "acg" -> "thr"
          "aag" -> "lys"
          "agg" -> "arg"
          "guu" -> "val"
          "gcu" -> "ala"
          "gau" -> "asp"
          "ggt" -> "gly"
          "guc" -> "val"
          "gcc" -> "ala"
          "gac" -> "asp"
          "ggc" -> "gly"
          "gua" -> "val"
          "gca" -> "ala"
          "gaa" -> "glu"
          "gga" -> "gly"
          "gug" -> "val"
          "gcg" -> "ala"
          "gag" -> "glu"
          "ggg" -> "gly"
        end

      [value | rest]
    end

    ribosome_worker = fn stack ->
      stack
    end

    ribosome = fn ->
      [
        [], :swap,
        ribosome_worker
      ]
    end

    assert [
      "caugaacauugaaaugugaaaaaugaaac",
      ribosome
    ] |> Amino.eval() == [["met", "asn", "ile", "glu", "met"], ["met", "lys"]]
  end
end
