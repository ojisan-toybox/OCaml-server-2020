# echo server practice

```
% dune build

% dune exec server

% curl -X POST -H "Content-Type: application/json" -d '{"Name":"a", "Age":"100"}'  http://localhost:8080
{"Name":"sensuikan1973", "Age":"100"}
```

## memo

OCaml の version は 4.09.1 を使う, 現時点で最新版の OCaml は LSP(merlin) が不安定

特定 version の環境は `opam switch create` で作れる.

補完は ocaml-lsp, これは merlin を wrap したやつで vscode と相性がいい

VSCode から ocamllsp が見れないときは `which ocamllsp` した絶対 path を設定に渡す

build は dune.

ocamlformat がなんか VSCode から動かないし、path 指定の口がないので自動 format は何か考えないといけない。

とはいえ、`dune build @fmt --auto-promote` で format できるのでしばらくこれ使う。
(ocamlformat の設定ファイルは必要)

`dune init project hoge` で hoge プロジェクトの雛形作れる。
なおカレントディレクトリに展開はできない。
project は library や executable など指定可能

`dune buildでコンパイルできる`

### dune

dune-project ファイルは project の root を示す。dune-project の name は test と subst の出力に使われる

```
(executable
 (public_name server)
 (name main)
 (libraries server))
```

の libraries は lib ディレクトリをみてる。そのなかにあるモジュールを探す。
そのモジュール名は lib の中にある dune の name で定義されている。
