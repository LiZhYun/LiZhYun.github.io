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

# A tldr containing a common abbreviation (e.g., i.e., vs., et al., Fig., Eq., approx.) must
# still count as one sentence. Run the checker against a scratch copy of the real data whose
# first tldr is replaced with one, and expect a clean pass.
tldr_root="$(mktemp -d)"
mkdir -p "$tldr_root/_data"
for f in _data/*.yml; do
  base="$(basename "$f")"
  [ "$base" = "publications.yml" ] || ln -s "$(pwd)/$f" "$tldr_root/_data/$base"
done
ln -s "$(pwd)/assets" "$tldr_root/assets"
ln -s "$(pwd)/_includes" "$tldr_root/_includes"
ruby -ryaml -e '
  pubs = YAML.load_file("_data/publications.yml")
  pubs.first["tldr"] = "A method, e.g. for agents, that works."
  File.write(ARGV[0], pubs.to_yaml)
' "$tldr_root/_data/publications.yml"
if ruby tools/check-data.rb --root "$tldr_root" --expect-total 14 --expect-selected 6 > tools/out/data-tldr-abbrev.txt 2>&1 \
  && grep -qF "DATA OK" tools/out/data-tldr-abbrev.txt; then
  echo "PASS tldr with 'e.g.' still counts as one sentence"
else
  echo "FAIL tldr abbreviation allowance:"; cat tools/out/data-tldr-abbrev.txt; fail=1
fi
rm -rf "$tldr_root"

exit $fail
