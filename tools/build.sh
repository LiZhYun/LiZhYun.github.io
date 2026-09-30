#!/usr/bin/env bash
# Gate 1: strict production build that prints no warnings.
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p tools/out
JEKYLL_ENV=production bundle exec jekyll build --strict_front_matter > tools/out/build.log 2>&1
status=$?
cat tools/out/build.log
if [ $status -ne 0 ]; then echo "BUILD FAILED (exit $status)"; exit 1; fi
if grep -iE 'warn|deprecat|error' tools/out/build.log; then echo "BUILD PRINTED WARNINGS"; exit 1; fi
echo "BUILD OK"
