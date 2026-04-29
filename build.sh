#!/usr/bin/env bash
# Regenerate slide thumbnails and rebuild giftly-pitch.pdf.
# Run from anywhere; it uses its own directory as the working root.
set -euo pipefail

cd "$(dirname "$0")"

SLIDES=(
  slide-1 slide-2 slide-3 slide-4 slide-5
  slide-6 slide-7 slide-8 slide-9 slide-10
  slide-a1 slide-a2 slide-a3 slide-a4
)

CHROMIUM="${CHROMIUM:-chromium}"
if ! command -v "$CHROMIUM" >/dev/null 2>&1; then
  if command -v chromium-browser >/dev/null 2>&1; then CHROMIUM=chromium-browser
  elif command -v google-chrome   >/dev/null 2>&1; then CHROMIUM=google-chrome
  else echo "error: no chromium / chrome binary found" >&2; exit 1
  fi
fi

if ! command -v pdfunite >/dev/null 2>&1; then
  echo "error: pdfunite not found (install poppler-utils)" >&2; exit 1
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

mode="${1:-all}"

render_pdf() {
  echo "→ rendering per-slide PDFs"
  for s in "${SLIDES[@]}"; do
    "$CHROMIUM" --headless --no-sandbox --disable-gpu \
      --no-pdf-header-footer --virtual-time-budget=4000 \
      --print-to-pdf="$WORK/$s.pdf" \
      "file://$PWD/$s.html" 2>/dev/null
  done
  echo "→ merging into giftly-pitch.pdf"
  pdfunite "${SLIDES[@]/#/$WORK/}".pdf giftly-pitch.pdf 2>/dev/null || \
  pdfunite $(printf "$WORK/%s.pdf " "${SLIDES[@]}") giftly-pitch.pdf
  echo "✓ giftly-pitch.pdf rebuilt ($(du -h giftly-pitch.pdf | cut -f1))"
}

render_thumbs() {
  echo "→ regenerating slide PNG thumbnails"
  for s in "${SLIDES[@]}"; do
    "$CHROMIUM" --headless --no-sandbox --disable-gpu \
      --hide-scrollbars --window-size=1920,1080 \
      --virtual-time-budget=4000 \
      --screenshot="$s.png" \
      "file://$PWD/$s.html" 2>/dev/null
  done
  echo "✓ thumbnails refreshed"
}

case "$mode" in
  pdf)    render_pdf ;;
  thumbs) render_thumbs ;;
  all)    render_thumbs; render_pdf ;;
  *)      echo "usage: $0 [all|pdf|thumbs]"; exit 1 ;;
esac
