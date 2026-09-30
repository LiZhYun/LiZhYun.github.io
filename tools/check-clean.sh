#!/usr/bin/env bash
# Task 1 gate: the al-folio fork is gone, papers/ is ignored, and the skeleton builds.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
for p in _posts _pages _projects _bibliography _sass _plugins bin \
         assets/js/common.js assets/css/main.scss assets/fonts assets/plotly assets/bibliography \
         assets/img/prof_pic.jpg assets/img/favicon.ico Dockerfile docker-compose.yml docker-local.yml \
         .all-contributorsrc CONTRIBUTING.md LICENSE .pre-commit-config.yaml compile-git-with-openssl.sh \
         mintty.2023-05-30_15-16-35.png .github/FUNDING.yml .github/stale.yml .github/ISSUE_TEMPLATE \
         .github/workflows/deploy-image.yml .github/workflows/deploy-docker-tag.yml \
         _data/cv.yml _data/coauthors.yml _data/venues.yml _data/repositories.yml \
         _includes/news.html _layouts/about2.html _layouts/bib.html robots.txt; do
  if [ -e "$p" ]; then echo "FAIL still present: $p"; fail=1; fi
done
if git grep -n "polyfill.io" -- . ':!docs' ':!tools/check-clean.sh' ':!tools/check-output.rb' >/dev/null 2>&1; then
  echo "FAIL polyfill.io still referenced:"; git grep -n "polyfill.io" -- . ':!docs' ':!tools/check-clean.sh' ':!tools/check-output.rb'; fail=1
fi
grep -qx 'papers/' .gitignore 2>/dev/null || { echo "FAIL papers/ not in .gitignore"; fail=1; }
git check-ignore -q papers/AAAI2025_AgentMixer.zip || { echo "FAIL papers/*.zip is not ignored"; fail=1; }
if tools/build.sh > /dev/null; then echo "PASS build"; else echo "FAIL build (see tools/out/build.log)"; fail=1; fi
[ -f _site/index.html ] || { echo "FAIL _site/index.html missing"; fail=1; }
[ $fail -eq 0 ] && echo "CLEAN OK"
exit $fail
