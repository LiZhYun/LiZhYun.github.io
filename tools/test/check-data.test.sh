#!/usr/bin/env bash
# Self-test for tools/check-data.rb: the real data must pass, and the broken fixture must
# fail with every expected message.
set -uo pipefail
cd "$(dirname "$0")/../.."
mkdir -p tools/out
fail=0
if ruby tools/check-data.rb --expect-total 14 --expect-selected 6 > tools/out/data-good.txt 2>&1; then
  echo "PASS real data"
else
  echo "FAIL real data:"; cat tools/out/data-good.txt; fail=1
fi
if ruby tools/check-data.rb --root tools/test/fixtures/bad > tools/out/data-bad.txt 2>&1; then
  echo "FAIL the broken fixture was accepted"; fail=1
else
  while IFS= read -r expected; do
    [ -z "$expected" ] && continue
    if grep -qF -- "$expected" tools/out/data-bad.txt; then echo "PASS caught: $expected"
    else echo "FAIL missed: $expected"; fail=1; fi
  done < tools/test/fixtures/bad/expected-errors.txt
fi
exit $fail
