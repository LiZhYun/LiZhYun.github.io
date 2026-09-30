#!/usr/bin/env bash
# Gate 2b: every external https:// URL in _data/*.yml responds.
# 2xx passes; 403/429 are warnings to check by hand (bot walls); anything else fails.
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p tools/out
grep -rhoE "https://[^\"' <>)]+" _data/*.yml | sed -E 's/[.,;]+$//' | sort -u > tools/out/urls.txt
fail=0; warn=0
while IFS= read -r url; do
  code=$(curl -sS -L -o /dev/null -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120 Safari/537.36' \
         --max-time 20 -w '%{http_code}' "$url" 2>/dev/null)
  code=${code:-000}
  case "$code" in
    2??)     echo "OK   $code $url" ;;
    403|429) echo "WARN $code $url"; warn=$((warn + 1)) ;;
    *)       echo "FAIL $code $url"; fail=$((fail + 1)) ;;
  esac
done < tools/out/urls.txt
echo "$(wc -l < tools/out/urls.txt) URLs: $fail failed, $warn to check by hand"
[ "$fail" -eq 0 ]
