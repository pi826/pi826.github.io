#!/usr/bin/env bash
# TeX (standalone, TikZ/tikz-cd/pgfplots等) を SVG に変換する。
# 使い方: ./scripts/tex2svg.sh figures-src/<slug>/fig1.tex
# 出力先: 入力パスの figures-src/ を public/figures/ に置き換えた場所
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "使い方: $0 figures-src/<slug>/<name>.tex" >&2
  exit 1
fi

src="$1"

case "$src" in
  figures-src/*) ;;
  *)
    echo "エラー: 入力パスは figures-src/ 以下である必要があります: $src" >&2
    exit 1
    ;;
esac

if [ "${src##*.}" != "tex" ]; then
  echo "エラー: 入力ファイルは .tex である必要があります: $src" >&2
  exit 1
fi

if [ ! -f "$src" ]; then
  echo "エラー: ファイルが見つかりません: $src" >&2
  exit 1
fi

src_dir="$(dirname "$src")"
base="$(basename "$src" .tex)"
out_dir="public/figures/${src_dir#figures-src/}"
log_file="$src_dir/$base.build.log"

mkdir -p "$out_dir"

compile() {
  local engine="$1"
  (cd "$src_dir" && "$engine" -interaction=nonstopmode -halt-on-error "$base.tex") \
    > "$log_file" 2>&1
}

show_error_log() {
  echo "エラー: TeXの変換に失敗しました。ログの該当箇所:" >&2
  if [ -f "$src_dir/$base.log" ]; then
    grep -n '^!' "$src_dir/$base.log" >&2 || tail -n 30 "$src_dir/$base.log" >&2
  else
    tail -n 30 "$log_file" >&2
  fi
}

cleanup() {
  rm -f "$src_dir/$base.aux" "$src_dir/$base.log" "$src_dir/$base.dvi" "$log_file"
}

engine=latex
if LC_ALL=C grep -q $'[\x80-\xFF]' "$src"; then
  engine=platex
fi

if ! compile "$engine"; then
  if [ "$engine" = "latex" ]; then
    echo "latex での変換に失敗したため platex にフォールバックします。" >&2
    if ! compile platex; then
      show_error_log
      cleanup
      exit 1
    fi
  else
    show_error_log
    cleanup
    exit 1
  fi
fi

if ! dvisvgm --font-format=woff2 -o "$src_dir/$base.svg" "$src_dir/$base.dvi" >> "$log_file" 2>&1; then
  echo "エラー: dvisvgm でのSVG化に失敗しました。ログ:" >&2
  tail -n 30 "$log_file" >&2
  cleanup
  exit 1
fi

mv "$src_dir/$base.svg" "$out_dir/$base.svg"
cleanup

echo "生成しました: $out_dir/$base.svg"
