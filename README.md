# echo server practice

```
% dune build

% dune exec server

% curl -X POST -H "Content-Type: application/json" -d '{"Name":"a", "Age":"100"}'  http://localhost:8080
{"Name":"a", "Age":"100"}
```

## Memo

OCaml の version は 4.09.1 を使う, 現時点で最新版の OCaml 4.10.0 は OCaml-LSP が内部で使っている Merlin のフォークが古く 4.10.0 に対応していない。

特定 version の環境は `opam switch create <version>` で作れる。

Language Server は OCaml Labs が公式にリリースしている OCaml-LSP を使う。
これは上でも書いた通り、Merlin によって成り立っている。

VSCode から `ocamllsp` バイナリが見れないときは `which ocamllsp` した絶対 path を設定で渡す。

ビルドシステムには dune を使う。

ocamlformat がなんか VSCode から動かないし、path 指定の口がないので自動 format は何か考えないといけない。

とはいえ、`dune build @fmt --auto-promote` で format できるのでしばらくこれ使う。
(ocamlformat の設定ファイルは必要)

`dune init {library,executable,test,project} hoge` で hoge の雛形作れる。
なおカレントディレクトリに展開はできない。

`dune build` でビルド可能。

### dune

dune-project:

```
(lang dune 2.5)
(name <name>)
```

dune-project ファイルはプロジェクト全体の設定などを定義するために使う。
dune-project の `name` は test と subst の出力に使われる。

dune (library):

```
(library
 (name <library-name>)
 <optional-fields>)
```

dune ファイルの library スタンザは OCaml のライブラリを作るために使う。
`name` フィールドは必須で、あとは全てオプショナルフィールド。

dune (executable):

```
(executable
 (name <name>)
 <optional-fields>)
```

dune ファイルの executable スタンザは実行可能ファイルを作るために使う。
これも同じく `name` フィールドのみ必須。

dune (共通):

libraries:

ライブラリを使いたい場合は、`libraries` フィールドで使うライブラリを列挙する。
現在のスコープで定義されているライブラリには、`name` または `public_name` を使える。
インストール済みライブラリ、または現在のワークスペースの一部であるが別のスコープにあるライブラリの場合は、`public_name` を使用する必要がある。 \*[スコープとは](https://dune.readthedocs.io/en/stable/concepts.html#scopes)
また、ライブラリ解決に関しては、インストール済みライブラリよりワークスペースの一部であるライブラリが常に優先される。
