#!/usr/bin/env bash
#------------------------------------------------------------------------------
# One-off image optimization: convert heavy raster sources to WebP.
#
#   - Photos / AI-generated art  -> WebP lossy q82
#   - Logos (text + transparency) -> WebP lossy q90
#   - Open Graph card            -> WebP lossy q85 (1200x630 kept)
#   - Favicons / chrome icons    -> left as PNG (compatibility)
#
# Large images are capped to a sensible max width before encoding. Originals
# are removed after a successful conversion (git retains the history).
#------------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")/.."

total_before=0
total_after=0

# convert <file> <quality> <maxwidth> [lossless]
convert_img() {
  local src="$1" q="$2" maxw="$3" lossless="${4:-}"
  [[ -f "$src" ]] || { echo "  skip (missing): $src"; return; }

  local before w resize_args=() out
  before=$(stat -c%s "$src")
  w=$(identify -format '%w' "${src}[0]" 2>/dev/null || echo 0)
  if [[ "$maxw" -gt 0 && "$w" -gt "$maxw" ]]; then
    resize_args=(-resize "$maxw" 0)
  fi

  out="${src%.*}.webp"
  if [[ -n "$lossless" ]]; then
    cwebp -quiet -lossless -z 9 "${resize_args[@]}" "$src" -o "$out"
  else
    cwebp -quiet -q "$q" -m 6 "${resize_args[@]}" "$src" -o "$out"
  fi

  local after; after=$(stat -c%s "$out")
  total_before=$((total_before + before))
  total_after=$((total_after + after))
  printf '  %7.0f KB -> %6.0f KB  %s\n' "$((before/1024))" "$((after/1024))" "$out"

  # Remove the original if the name changed (png/jpg -> webp)
  [[ "$src" != "$out" ]] && rm -f "$src"
}

echo "== Featured / content photos (q82, cap 1600w) =="
while IFS= read -r -d '' f; do convert_img "$f" 82 1600; done \
  < <(find content -type f \( -iname 'featured*.png' -o -iname 'featured*.jpeg' -o -iname 'featured*.jpg' \) -print0)

echo "== Club gallery photos (q82, cap 1280w) =="
for f in \
  content/tijuana/resenas/club-escape/escape-reglas.jpg \
  content/tijuana/resenas/club-escape/escape-sala.jpeg \
  content/tijuana/resenas/club-medusa/medusa-camino.jpeg \
  content/tijuana/resenas/club-medusa/medusa-exterior.jpeg \
  content/tijuana/resenas/club-medusa/medusa-no-singles.jpg \
  content/tijuana/resenas/club-medusa/medusa-reglas.jpeg ; do
  convert_img "$f" 82 1280
done

echo "== Homepage hero (q82, cap 2048w) =="
convert_img assets/hero-homepage.png 82 2048

echo "== Author avatar (q82, cap 600w) =="
convert_img assets/author_Anteros.png 82 600

echo "== Logos (q90, cap 1000w) =="
convert_img assets/mxkinksters-logo.png 90 1000
convert_img assets/img/tkm-logo.png 90 1000

echo "== Open Graph default card (q85, keep 1200x630) =="
convert_img assets/img/og-default.png 85 0
convert_img static/img/og-default.png 85 0

echo
printf 'TOTAL: %.1f MB -> %.1f MB  (saved %.1f MB)\n' \
  "$(echo "$total_before/1048576" | bc -l)" \
  "$(echo "$total_after/1048576" | bc -l)" \
  "$(echo "($total_before-$total_after)/1048576" | bc -l)"
