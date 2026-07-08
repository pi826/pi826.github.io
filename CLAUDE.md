# CLAUDE.md

## プロジェクト概要

個人ホームページ。数学記事のブログを中心に、自己紹介・研究/業績・作品紹介ページを持つ。
言語はすべて日本語。GitHub Pages で公開する。

## 技術スタック

- **フレームワーク**: Astro（静的サイト生成）
- **記事形式**: Markdown（.md / .mdx）＋ LaTeX 数式
- **数式表示**: KaTeX（`remark-math` + `rehype-katex`）でクライアント負荷なしにビルド時レンダリング
- **図（TikZ等）**: `scripts/tex2svg` で TeX コードから SVG を生成し、記事に画像として埋め込む
- **デプロイ**: GitHub Actions → GitHub Pages（`main` へ push で自動デプロイ）
- **パッケージ管理**: npm

## ディレクトリ構成

```
/
├── src/
│   ├── content/
│   │   └── blog/          # 数学記事（Markdown）。1記事=1ファイル
│   ├── pages/             # about, research, works などの固定ページ
│   ├── layouts/           # 共通レイアウト
│   └── components/        # ヘッダー・記事カードなどのUI部品
├── public/
│   └── figures/           # tex2svg で生成した図（記事slugごとにサブフォルダ）
├── figures-src/           # 図のTeXソース（.tex）。生成SVGと対で管理する
├── scripts/
│   └── tex2svg.sh         # TeX → SVG 変換スクリプト
└── .github/workflows/deploy.yml
```

## コマンド

```bash
npm run dev        # 開発サーバー起動 (localhost:4321)
npm run build      # 本番ビルド (dist/)
npm run preview    # ビルド結果の確認

# 図の生成: figures-src/<slug>/fig1.tex → public/figures/<slug>/fig1.svg
./scripts/tex2svg.sh figures-src/<slug>/fig1.tex
```

## tex2svg スクリプトの仕様

- 入力: `standalone` ドキュメントクラスの .tex ファイル（TikZ・tikz-cd・pgfplots 等を想定）
- 処理: `latex`（DVI出力）→ `dvisvgm --font-format=woff2` で SVG 化
- 出力先: 入力パスの `figures-src/` を `public/figures/` に置き換えた場所
- 日本語を含む図は `platex` + `dvisvgm` にフォールバックする
- 生成に失敗したら LaTeX のログの該当エラー行を表示すること

## 記事の書き方

- 記事は `src/content/blog/<slug>.md` に置く
- frontmatter は次のスキーマに従う:

```yaml
---
title: "記事タイトル"
date: 2026-07-08
tags: ["代数", "圏論"]
description: "1〜2文の要約"
draft: false
---
```

- インライン数式は `$...$`、ディスプレイ数式は `$$...$$`
- 定理・定義・証明は共通コンポーネント（`<Theorem>`, `<Definition>`, `<Proof>` 等）を使う
- 可換図式や図形は本文に直接書かず、`figures-src/<slug>/` に .tex を置き、tex2svg で生成した SVG を `![説明](/figures/<slug>/fig1.svg)` で埋め込む
- 図の TeX ソースは削除しない（後から修正・再生成するため）

## コーディング規約

- コメント・命名は英語、UI テキストは日本語
- KaTeX 非対応のマクロは使わない（対応表: https://katex.org/docs/supported.html）。必要なマクロは `katex` オプションの `macros` に定義する
- スタイルは Astro コンポーネント内の scoped CSS を基本とし、全体テーマは CSS 変数で管理
- ダークモード対応（`prefers-color-scheme`）。数式・SVG図が両テーマで読めることを確認する

## 注意事項

- `public/figures/` 内の SVG は生成物だが、GitHub Actions 上で TeX 環境を用意しないためコミットに含める
- ビルド前に `npm run build` が警告なしで通ることを確認する
- 記事の数学的内容は勝手に変更しない。誤りを見つけた場合は指摘のみ行う
