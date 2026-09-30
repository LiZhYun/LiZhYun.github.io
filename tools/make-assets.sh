#!/usr/bin/env bash
# Regenerates every image the site serves. Sources:
#   - committed: the hand-drawn avatar, the approved mockup's assets, the OCRA figure
#   - local only (gitignored papers/): paper zips and three arXiv e-prints
# Usage: tools/make-assets.sh
set -euo pipefail
cd "$(dirname "$0")/.."

SPEC=docs/superpowers/specs/2026-09-30-homepage-redesign
MOCK="$SPEC/mockup/assets"
SRC="$SPEC/sources"
AV="$SPEC/cropped_circle_image.png"
OUT=assets/img
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT/logos" "$OUT/pubs"

# --- avatar and icons (the avatar has transparent corners) ---
convert "$AV" -resize 480x480 "$OUT/avatar.png"
convert "$AV" -resize 32x32 "$OUT/favicon.png"
convert "$AV" -resize 32x32 favicon.ico
convert -size 180x180 xc:white \( "$AV" -resize 164x164 \) -gravity center -composite -alpha off "$OUT/apple-touch-icon.png"

# --- logos, already cropped and sized in the approved mockup ---
cp "$MOCK/logo_aalto_mark.png" "$OUT/logos/aalto.png"
cp "$MOCK/logo_uestc_s.png"    "$OUT/logos/uestc.png"
cp "$MOCK/logo_ncepu_s.png"    "$OUT/logos/ncepu.png"

# to_webp SRC DST: at most 800px wide (never upscaled) and at most 80 KB.
to_webp() {
  local src=$1 dst=$2 q=82 w
  w=$(identify -format '%w' "$src[0]")
  local resize=()
  if [ "$w" -gt 800 ]; then resize=(-resize 800 0); fi
  while true; do
    cwebp -quiet -q "$q" "${resize[@]}" "$src" -o "$dst"
    if [ "$(stat -c %s "$dst")" -le 81920 ]; then break; fi
    if [ "$q" -le 40 ]; then echo "cannot get $dst under 80 KB" >&2; exit 1; fi
    q=$((q - 8))
  done
}

# pdf_to_png PDF DST: rasterize a one-page figure, trim, add a 12px white margin.
pdf_to_png() {
  pdftoppm -png -r 200 -singlefile "$1" "$TMP/fig"
  convert "$TMP/fig.png" -trim +repage -bordercolor white -border 12 "$2"
}

# --- thumbnails that were already cropped for the mockup ---
to_webp "$MOCK/retarget_panorama.jpg" "$OUT/pubs/retargeting.webp"
to_webp "$MOCK/rocl_fig1_left.jpg"    "$OUT/pubs/rethinking-ocl.webp"
to_webp "$MOCK/egox.jpg"              "$OUT/pubs/egoxedit.webp"
to_webp "$MOCK/agentmixer.jpg"        "$OUT/pubs/agentmixer.webp"
to_webp "$MOCK/bpta.jpg"              "$OUT/pubs/bpta.webp"
to_webp "$MOCK/dms.jpg"               "$OUT/pubs/dms.webp"
to_webp "$SRC/ocra.jpg"               "$OUT/pubs/ocra.webp"

# --- figures from the paper zips ---
unzip -p papers/Zhiyuan___SE_AAMAS2026_COMPASS.zip figs/compass.pdf > "$TMP/compass.pdf"
pdf_to_png "$TMP/compass.pdf" "$TMP/compass.png"
to_webp "$TMP/compass.png" "$OUT/pubs/compass.webp"
unzip -p papers/Zhiyuan___TPAMI26_OCL.zip figures/fig1_study_overview_v15.pdf > "$TMP/recipe.pdf"
pdf_to_png "$TMP/recipe.pdf" "$TMP/recipe.png"
to_webp "$TMP/recipe.png" "$OUT/pubs/default-recipe.webp"

# --- co-authored papers: figures from their arXiv e-prints (owner approves in Step 6) ---
A=papers/arxiv-2602.02699/figs
convert \( "$A/velocity_celeba.png" "$A/velocity_celeba_masked_0_5.png" -resize 600x600 +append \) \
        \( "$A/velocity_celeba_masked_0_95.png" "$A/velocity_celeba_masked_0_98.png" -resize 600x600 +append \) \
        -append "$TMP/ssd.png"
to_webp "$TMP/ssd.png" "$OUT/pubs/sparsely-supervised-diffusion.webp"
pdf_to_png papers/arxiv-2205.10016/figs/spmarl.pdf "$TMP/lpmc.png"
to_webp "$TMP/lpmc.png" "$OUT/pubs/lpmc.webp"
pdf_to_png papers/arxiv-2311.01953/figs/matrix_game_value.pdf "$TMP/optimappo.png"
to_webp "$TMP/optimappo.png" "$OUT/pubs/optimappo.webp"

echo "ASSETS BUILT"
