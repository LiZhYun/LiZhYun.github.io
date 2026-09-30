#!/usr/bin/env bash
# Verifies the served images exist with the sizes the spec requires (spec §3, §4).
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
ok()  { echo "PASS $1"; }
bad() { echo "FAIL $1"; fail=1; }
dims() { identify -format '%wx%h' "$1[0]" 2>/dev/null; }

[ "$(dims assets/img/avatar.png)" = "480x480" ] && ok "avatar 480x480" || bad "assets/img/avatar.png must be 480x480"
[ "$(dims assets/img/favicon.png)" = "32x32" ] && ok "favicon.png 32x32" || bad "assets/img/favicon.png must be 32x32"
[ "$(dims favicon.ico)" = "32x32" ] && ok "favicon.ico 32x32" || bad "favicon.ico (site root) must be 32x32"
opaque=$(identify -format '%[opaque]' assets/img/apple-touch-icon.png 2>/dev/null | tr 'A-Z' 'a-z')
if [ "$(dims assets/img/apple-touch-icon.png)" = "180x180" ] && [ "$opaque" = "true" ]; then ok "apple-touch-icon 180x180 opaque"
else bad "assets/img/apple-touch-icon.png must be 180x180 and opaque"; fi
for l in aalto uestc ncepu; do
  [ -s "assets/img/logos/$l.png" ] && ok "logo $l" || bad "assets/img/logos/$l.png missing"
done
for t in retargeting sparsely-supervised-diffusion rethinking-ocl compass egoxedit default-recipe \
         lpmc agentmixer optimappo bpta dms ocra; do
  f="assets/img/pubs/$t.webp"
  if [ ! -s "$f" ]; then bad "$f missing"; continue; fi
  w=$(identify -format '%w' "$f" 2>/dev/null); s=$(stat -c %s "$f")
  if [ "$w" -le 800 ] && [ "$s" -le 81920 ]; then ok "$f (${w}px, ${s} B)"
  else bad "$f is ${w}px / ${s} B (max 800px / 81920 B)"; fi
done
[ ! -e assets/img/publication_preview ] && ok "old previews removed" || bad "assets/img/publication_preview still present"
[ ! -e assets/img/cropped_circle_image.png ] && ok "avatar source moved to docs/" || bad "assets/img/cropped_circle_image.png must move to docs/"
[ -s assets/pdf/Li_Zhiyuan_CV.pdf ] && [ -s assets/pdf/Li_Zhiyuan_CV_zh.pdf ] && ok "both CVs present" || bad "a CV PDF is missing"
exit $fail
