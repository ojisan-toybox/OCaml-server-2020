# いまどきの OCaml

OCaml の version は 4.09.1 を使う, 現時点で最新版の OCaml は LSP(merlin) が不安定

特定 version の環境は `opam switch create` で作れる.

補完は ocaml-lsp, これは merlin を wrap したやつで vscode と相性がいい

VSCode から ocamllsp が見れないときは `which ocamllsp` した絶対 path を設定に渡す

build は dune.

ocamlformat がなんか VSCode から動かないし、path 指定の口がないので自動 format は何か考えないといけない。

とはいえ、`dune build @fmt --auto-promote` で format できるのでしばらくこれ使う。
(ocamlformat の設定ファイルは必要)
