# Homepage Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the al-folio fork in `LiZhYun.github.io` with a small Jekyll 4 site that renders the approved "D+" home page from `_data/*.yml`.

**Architecture:**
- One page: `_layouts/home.html` inside `_layouts/default.html`, rendering from `_data/*.yml` through small includes.
- One stylesheet, `assets/css/site.css`. It has light and dark color tokens, and every other rule uses them.
- One dependency-free script, `assets/js/site.js`, for the Selected/All toggle, "Show older" and the theme button.
- Every behavior works without JS in its default state.
- Quality gates are small scripts in `tools/`.
- GitHub Actions builds the site, runs html-proofer and publishes `_site` to `gh-pages`.

**Tech Stack:**
- Site: Jekyll 4.4.1, jekyll-seo-tag 2.9.1, jekyll-sitemap 1.4.0, Liquid 4 in strict mode, plain CSS and JS.
- Local checks: Ruby 3.2 (system; no dev headers), Nokogiri 1.18 (system gem), Node 22 with playwright-core driving `/usr/bin/google-chrome`, ImageMagick 6, cwebp, poppler `pdftoppm`.
- CI: Ruby 3.3 and html-proofer 5.

**Spec:** `docs/superpowers/specs/2026-09-30-homepage-redesign-design.md` (approved). Executors read the spec and this plan. The visual reference is `docs/superpowers/specs/2026-09-30-homepage-redesign/mockup/index.html` (screenshot `mockup/D-rich.jpg`).

## Global Constraints

- **Branch:** work on `redesign-2026`. Commit only with the owner's approval, which is given once at execution start for per-task commits on this branch. Never push without the owner's explicit go-ahead. Every commit message ends with the two attribution lines from the session's system reminder (`Co-Authored-By: …` and `Claude-Session: …`).
- **Never commit `papers/`.** It holds under-review sources, co-author photos and e-mails. It is gitignored in Task 1.
- **Content** comes only from the spec §4–§5 and the data files below. Never invent facts, numbers or links.
- **No corresponding-author marks** (†) anywhere on the site.
- **Colors:** every color in `site.css` is a custom property defined in the light token block (`:root { … }`) or the two identical dark token blocks. Component rules contain no literal colors (`#…`, `rgb(…)`, `hsl(…)`); the keywords `transparent` and `currentColor` are allowed.
- **URLs:**
  - Every internal URL in templates goes through `relative_url`, and anchors are root-relative (`/#publications`).
  - Data-file link values are full `https://` URLs.
  - arXiv links are stored as `https://arxiv.org/abs/<id>`.
- **Width:**
  - No fixed page widths: containers use `width: min(1110px, 100% - 48px)`.
  - No horizontal scroll at any width from 320px.
- **Thumbnails:** `assets/img/pubs/*.webp`, ≤ 800px wide, ≤ 81920 bytes.
- **Liquid:** strict (`error_mode: strict`, `strict_filters: true`). Never apply `date` or `date_to_string` to news dates.
- **Local Ruby:** no dev headers, so native gems cannot compile.
  - Use the system gems with `bundle install --local`.
  - Pure-Ruby gems not already installed go to the user gem dir with `gem install --user-install --ignore-dependencies`.
  - html-proofer runs only in CI; locally `tools/check-internal.rb` performs the same internal checks.
  - Never use `sudo`.

## File map

| Path | Responsibility | Task |
|---|---|---|
| `Gemfile`, `Gemfile.lock` | Jekyll + two plugins, resolved against locally installed gems | 1 |
| `_config.yml` | site metadata, strict Liquid, excludes, sitemap default for the Chinese CV | 1 |
| `.gitignore` | build output, deps, `papers/`, `tools/out/` | 1 |
| `index.html` | home page front matter (layout, SEO) | 1 |
| `tools/build.sh` | gate 1: strict production build, fails on warnings | 1 |
| `tools/check-clean.sh` | Task 1 gate: old theme gone, `papers/` ignored | 1 |
| `tools/make-assets.sh` | regenerates avatar, icons, logos and 12 thumbnails from sources | 2 |
| `tools/check-assets.sh` | image sizes and presence | 2 |
| `docs/superpowers/specs/2026-09-30-homepage-redesign/cropped_circle_image.png`, `…/sources/ocra.jpg` | committed sources for images | 2 |
| `assets/img/**`, `favicon.ico` | served images | 2 |
| `_data/*.yml` | all page content | 3 |
| `_includes/icons/*.svg` | inline stroke icons referenced by `profile.yml` | 3 |
| `tools/check-data.rb`, `tools/test/check-data.test.sh`, `tools/test/fixtures/bad/**` | gate 3 and its self-test | 3 |
| `_layouts/default.html`, `_layouts/home.html` | page shell and home page | 4 |
| `_includes/chip.html`, `timeline-row.html`, `news-row.html`, `pub-row.html` | repeated fragments | 4 |
| `assets/css/site.css` | tokens, components, responsive, motion | 4 (dark tokens: 5) |
| `tools/package.json`, `tools/package-lock.json`, `tools/browser.mjs` | browser gates 4, 5 and 7 | 4 |
| `assets/js/site.js` | toggle, show older, theme | 5 |
| `tools/contrast.mjs` | gate 6 | 6 |
| `_layouts/redirect.html`, `publications/index.html`, `projects/index.html`, `projects/compass/index.html`, `blog/index.html`, `404.html` | old URLs, 404 page | 7 |
| `tools/check-output.rb` | SEO, sitemap, robots, redirects, 404 | 7 |
| `tools/check-internal.rb`, `tools/check-links.sh` | gate 2 (local internal, external) | 8 |
| `.github/workflows/deploy.yml`, `README.md` | CI/deploy and owner docs | 9 |

---

### Task 1: Remove the al-folio fork and build an empty strict skeleton

**Files:**
- Delete: see Step 3. This covers every al-folio path, but keeps `assets/pdf/`, `assets/img/publication_preview/`, `assets/img/cropped_circle_image.png`, `.github/workflows/deploy.yml` (replaced in Task 9) and `docs/`.
- Create: `Gemfile`, `_config.yml`, `.gitignore`, `index.html`, `_layouts/default.html` (temporary, replaced in Task 4), `_layouts/home.html` (temporary, replaced in Task 4), `tools/build.sh`, `tools/check-clean.sh`.

**Interfaces:**
- Produces:
  - `tools/build.sh`: exits 0 only if the production build succeeds and prints no warn/deprecat/error lines. The log goes to `tools/out/build.log`.
  - `_config.yml` keys used later: `site.title`, `site.url`, `site.lang`, `site.social`.

- [ ] **Step 1: Write the failing gate `tools/check-clean.sh`**

```bash
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
if git grep -n "polyfill.io" -- . ':!docs' >/dev/null 2>&1; then
  echo "FAIL polyfill.io still referenced:"; git grep -n "polyfill.io" -- . ':!docs'; fail=1
fi
grep -qx 'papers/' .gitignore 2>/dev/null || { echo "FAIL papers/ not in .gitignore"; fail=1; }
git check-ignore -q papers/AAAI2025_AgentMixer.zip || { echo "FAIL papers/*.zip is not ignored"; fail=1; }
if tools/build.sh > /dev/null; then echo "PASS build"; else echo "FAIL build (see tools/out/build.log)"; fail=1; fi
[ -f _site/index.html ] || { echo "FAIL _site/index.html missing"; fail=1; }
[ $fail -eq 0 ] && echo "CLEAN OK"
exit $fail
```

Save it as `tools/check-clean.sh` and run `chmod +x tools/check-clean.sh`.

- [ ] **Step 2: Run it to verify it fails**

Run: `tools/check-clean.sh`
Expected: many `FAIL still present: …` lines, and the script exits 1. `tools/build.sh` does not exist yet, so the build line also fails.

- [ ] **Step 3: Delete the al-folio fork**

```bash
git rm -r -q --ignore-unmatch _posts _pages _projects _bibliography _data _includes _layouts _sass _plugins blog bin \
  assets/js assets/css assets/fonts assets/plotly assets/bibliography assets/img/prof_pic.jpg assets/img/favicon.ico \
  Dockerfile docker-compose.yml docker-local.yml .all-contributorsrc CONTRIBUTING.md LICENSE .pre-commit-config.yaml \
  compile-git-with-openssl.sh mintty.2023-05-30_15-16-35.png README.md 404.html robots.txt \
  .github/FUNDING.yml .github/stale.yml .github/ISSUE_TEMPLATE .github/workflows/deploy-image.yml \
  .github/workflows/deploy-docker-tag.yml
rm -f Gemfile.lock   # untracked, root-owned stale lockfile; the directory is user-owned so no sudo is needed
git status --short | head -50
```

Expected: `git status` shows only deletions (`D`), plus the untracked `papers/`, `docs/`, `assets/pdf/Li_Zhiyuan_CV_zh.pdf` and `assets/img/cropped_circle_image.png`, and the modified `assets/pdf/Li_Zhiyuan_CV.pdf`.

- [ ] **Step 4: Write the skeleton files**

`Gemfile`:

```ruby
source "https://rubygems.org"

gem "jekyll", "~> 4.4"
gem "webrick", "~> 1.8" # needed by `jekyll serve` on Ruby >= 3.0

group :jekyll_plugins do
  gem "jekyll-seo-tag", "~> 2.8"
  gem "jekyll-sitemap", "~> 1.4"
end
```

`_config.yml`:

```yaml
# Site settings. All page content lives in _data/*.yml (see README.md).
title: "Zhiyuan Li (李志圆)"
url: "https://lizhyun.github.io"
baseurl: ""
author: Zhiyuan Li
lang: en
social:
  name: Zhiyuan Li
  links:
    - https://scholar.google.com/citations?user=1GYbhX0AAAAJ
    - https://github.com/LiZhYun
    - https://orcid.org/0000-0002-1804-3485

plugins:
  - jekyll-seo-tag
  - jekyll-sitemap

liquid:
  error_mode: strict
  strict_filters: true

exclude:
  - docs/
  - papers/
  - tools/
  - README.md
  - Gemfile
  - Gemfile.lock
  - vendor/
  - node_modules/
  - .bundle/

defaults:
  # Published and linked from the page, but not advertised to search engines.
  - scope:
      path: "assets/pdf/Li_Zhiyuan_CV_zh.pdf"
    values:
      sitemap: false
```

Note: there is deliberately no `description` key. jekyll-seo-tag would append it to the home `<title>`.

`.gitignore` (replace the whole file):

```
_site/
.jekyll-cache/
.jekyll-metadata
.sass-cache/
.bundle/
vendor/
node_modules/
tools/out/
papers/
.DS_Store
```

`index.html`:

```html
---
layout: home
description: "Postdoctoral researcher at Aalto University working on multi-agent reinforcement learning, robotics and foundation models."
image: /assets/img/avatar.png
seo:
  type: Person
  name: Zhiyuan Li
---
```

`_layouts/default.html` (temporary, replaced in Task 4):

```html
<!doctype html>
<html lang="{{ site.lang }}">
<head>
<meta charset="utf-8">
{% seo %}
</head>
<body>
{{ content }}
</body>
</html>
```

`_layouts/home.html` (temporary, replaced in Task 4):

```html
---
layout: default
---
<p>Zhiyuan Li</p>
```

`tools/build.sh`:

```bash
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
```

Run: `chmod +x tools/build.sh`

- [ ] **Step 5: Resolve gems against what is installed locally**

```bash
gem install --user-install --no-document --ignore-dependencies jekyll-seo-tag -v 2.9.1
bundle lock --local
bundle lock --local --add-platform x86_64-linux
bundle install --local
```

Expected: `Bundle complete!`, and `Gemfile.lock` lists `jekyll (4.4.1)`, `jekyll-seo-tag (2.9.1)`, `jekyll-sitemap (1.4.0)` and `PLATFORMS x86_64-linux`.

If `bundle lock --local` reports a missing pure-Ruby gem, install it with `gem install --user-install --no-document --ignore-dependencies <name> -v <version>` and repeat.

- [ ] **Step 6: Run the gate to verify it passes**

Run: `tools/check-clean.sh`
Expected: `PASS build` and `CLEAN OK`, exit 0.

- [ ] **Step 7: Commit**

```bash
git add -A -- . ':!papers' ':!assets/img/cropped_circle_image.png' ':!assets/pdf' ':!docs'
git add docs/superpowers/specs docs/superpowers/plans
git status --short | grep -v '^D ' | head -30   # review: no papers/, no assets/pdf yet
git commit -m "chore: remove al-folio fork and add strict Jekyll skeleton

Co-Authored-By: <attribution line 1 from the system reminder>
Claude-Session: <attribution line 2 from the system reminder>"
```

(`assets/pdf` and the avatar are committed in Task 2, once their final places are set.)

---

### Task 2: Generate every served image from committed sources

**Files:**
- Move: `assets/img/cropped_circle_image.png` → `docs/superpowers/specs/2026-09-30-homepage-redesign/cropped_circle_image.png`
- Copy: `assets/img/publication_preview/OCRA.jpg` → `docs/superpowers/specs/2026-09-30-homepage-redesign/sources/ocra.jpg`, then delete `assets/img/publication_preview/`
- Create: `tools/make-assets.sh`, `tools/check-assets.sh`
- Generate:
  - `assets/img/avatar.png`, `assets/img/favicon.png`, `assets/img/apple-touch-icon.png`, `favicon.ico`
  - `assets/img/logos/{aalto,uestc,ncepu}.png`
  - `assets/img/pubs/{retargeting,sparsely-supervised-diffusion,rethinking-ocl,compass,egoxedit,default-recipe,lpmc,agentmixer,optimappo,bpta,dms,ocra}.webp`
- Commit: `assets/pdf/Li_Zhiyuan_CV.pdf` (Sept 2026) and `assets/pdf/Li_Zhiyuan_CV_zh.pdf`

**Interfaces:**
- Consumes: `papers/*.zip` and `papers/arxiv-<id>/` (local only).
- Produces: the thumbnail file names above, which `_data/publications.yml` (Task 3) references exactly. Logo file names `aalto.png`, `uestc.png` and `ncepu.png` are used by `_data/education.yml` and `_data/experience.yml`.

- [ ] **Step 1: Write the failing gate `tools/check-assets.sh`**

```bash
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
```

Run: `chmod +x tools/check-assets.sh`

- [ ] **Step 2: Run it to verify it fails**

Run: `tools/check-assets.sh`
Expected: `FAIL` lines for the avatar, icons, logos and all 12 thumbnails. Exit 1.

- [ ] **Step 3: Move the committed sources into place**

```bash
S=docs/superpowers/specs/2026-09-30-homepage-redesign
mkdir -p "$S/sources"
mv assets/img/cropped_circle_image.png "$S/cropped_circle_image.png"   # untracked file, so a plain mv
cp assets/img/publication_preview/OCRA.jpg "$S/sources/ocra.jpg"
git rm -r -q assets/img/publication_preview
# arXiv sources for the three co-authored papers (skip any already downloaded)
for id in 2602.02699 2205.10016 2311.01953; do
  d="papers/arxiv-$id"
  if [ ! -f "$d/main.tex" ]; then
    mkdir -p "$d" && curl -sL -A "Mozilla/5.0" -o "$d/src.tgz" "https://arxiv.org/e-print/$id" && tar xzf "$d/src.tgz" -C "$d"
  fi
done
ls papers/arxiv-2602.02699/figs/velocity_celeba.png papers/arxiv-2205.10016/figs/spmarl.pdf papers/arxiv-2311.01953/figs/matrix_game_value.pdf
```

Expected: the final `ls` prints all three paths.

- [ ] **Step 4: Write `tools/make-assets.sh`**

```bash
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
```

Run: `chmod +x tools/make-assets.sh && tools/make-assets.sh`
Expected: `ASSETS BUILT`.

- [ ] **Step 5: Run the gate to verify it passes**

Run: `tools/check-assets.sh`
Expected: every line is `PASS`, exit 0.

- [ ] **Step 6: Owner approval of the three co-author thumbnails**

```bash
mkdir -p tools/out
montage assets/img/pubs/sparsely-supervised-diffusion.webp assets/img/pubs/lpmc.webp assets/img/pubs/optimappo.webp \
  -tile 3x1 -geometry 400x268+12+12 -background white tools/out/coauthor-thumbs.jpg
```

Send `tools/out/coauthor-thumbs.jpg` to the owner (SendUserFile). The three images are: Sparsely Supervised Diffusion (0/50/95/98% masking), LPMC (teacher–student curriculum diagram) and OptiMAPG (matrix-game values with and without optimism).

For any image the owner rejects:
- delete its `.webp`;
- remove its name from the loop in `tools/check-assets.sh` and its lines from `tools/make-assets.sh`;
- in Task 3, drop the `thumb:` line of that paper so it renders as a compact row.

Re-run `tools/check-assets.sh` (expect PASS).

- [ ] **Step 7: Commit**

```bash
git add tools/make-assets.sh tools/check-assets.sh assets/img favicon.ico assets/pdf \
  docs/superpowers/specs/2026-09-30-homepage-redesign/cropped_circle_image.png \
  docs/superpowers/specs/2026-09-30-homepage-redesign/sources
git status --short | grep papers && echo "STOP: papers/ must not be staged"
git commit -m "feat: generate avatar, icons, logos and paper thumbnails; add Sept 2026 CVs

Co-Authored-By: <attribution line 1>
Claude-Session: <attribution line 2>"
```

---

### Task 3: Content data files and the data gate

**Files:**
- Create:
  - `_data/profile.yml`, `_data/highlights.yml`, `_data/news.yml`, `_data/publications.yml`
  - `_data/education.yml`, `_data/experience.yml`, `_data/awards.yml`, `_data/service.yml`, `_data/teaching.yml`
  - `_includes/icons/{email,scholar,github,orcid,doc,agents,loop,robot,layers,arrow}.svg`
  - `tools/check-data.rb`, `tools/test/check-data.test.sh`
  - `tools/test/fixtures/bad/_data/{publications,news,profile}.yml`, `tools/test/fixtures/bad/expected-errors.txt`

**Interfaces:**
- Consumes: the thumbnail and logo file names from Task 2.
- Produces the data shapes Task 4 renders:
  - `site.data.profile`: `name`, `name_zh`, `pinyin[]`, `role`, `org`, `location`, `email`, `scholar_url`, `bio[]` (HTML), `chips[]` (`icon`, `label`, `href`, optional `mono: true` or `lang: zh`), `interests[]` (`icon`, `label`), `scholar{citations:int, h_index:int, updated:Date}`.
  - `site.data.highlights[]`: `emoji`, `bold`, `rest`.
  - `site.data.news[]`: `date` ("YYYY" | "YYYY-MM"), `emoji`, `html`, optional `older: true` / `new: true`.
  - `site.data.publications[]`: spec §4 fields, with link keys `paper`/`arxiv`/`oa`/`code`/`project`.
  - `site.data.education[]`: `institution`, `logo`, `degree`, `dates`.
  - `site.data.experience[]`: `institution`, `logo`, `role`, optional `note`, `dates`.
  - `site.data.awards[]`: `emoji`, `title`, optional `org`, `year` (string).
  - `site.data.service[]`: `label`, `text`.
  - `site.data.teaching[]`: `html`.
  - `_includes/icons/<name>.svg`: one `<svg class="ico" …>` each.
- `tools/check-data.rb [--root DIR] [--expect-total N] [--expect-selected N]` prints `DATA OK` and exits 0, or prints `ERROR …` lines and exits 1.

- [ ] **Step 1: Write `tools/check-data.rb`**

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# Gate 3: validates _data/*.yml against the design spec (§4, §5).
# Usage: ruby tools/check-data.rb [--root DIR] [--expect-total N] [--expect-selected N]
require "yaml"
require "date"
require "optparse"
require "shellwords"

opts = { root: File.expand_path("..", __dir__) }
OptionParser.new do |o|
  o.on("--root DIR") { |v| opts[:root] = File.expand_path(v) }
  o.on("--expect-total N", Integer) { |v| opts[:total] = v }
  o.on("--expect-selected N", Integer) { |v| opts[:selected] = v }
end.parse!

ROOT = opts[:root]
VENUE_KEYS = %w[neurips icml aaai arxiv nn tnsm eaai apin aamas tpami].freeze
TYPES = ["Conference", "Journal", "Preprint", "Workshop", "Under review"].freeze
LINK_KEYS = %w[paper arxiv oa code project].freeze
MAX_W = 800
MAX_BYTES = 80 * 1024
ERRORS = []

def err(msg)
  ERRORS << msg
end

def load_data(name)
  path = File.join(ROOT, "_data", "#{name}.yml")
  unless File.exist?(path)
    err("#{name}.yml: missing")
    return nil
  end
  YAML.safe_load(File.read(path), permitted_classes: [Date])
rescue Psych::SyntaxError => e
  err("#{name}.yml: YAML error: #{e.message}")
  nil
end

def image_width(path)
  `identify -format %w #{Shellwords.escape("#{path}[0]")} 2>/dev/null`.to_i
end

def nonempty_string?(v)
  v.is_a?(String) && !v.strip.empty?
end

# ---------- publications ----------
pubs = load_data("publications")
if pubs
  unless pubs.is_a?(Array) && !pubs.empty?
    err("publications.yml: must be a non-empty list")
    pubs = []
  end
  prev_year = nil
  new_flags = 0
  pubs.each_with_index do |p, i|
    unless p.is_a?(Hash)
      err("publications[#{i}]: not a mapping")
      next
    end
    tag = "publications[#{i}] (#{p['title'].to_s[0, 40]})"
    %w[title venue tldr].each { |k| err("#{tag}: '#{k}' must be a non-empty string") unless nonempty_string?(p[k]) }
    authors = p["authors"]
    if authors.is_a?(Array) && !authors.empty? && authors.all? { |a| nonempty_string?(a) }
      err("#{tag}: authors must include 'Zhiyuan Li'") unless authors.include?("Zhiyuan Li")
    else
      err("#{tag}: 'authors' must be a non-empty list of names")
    end
    err("#{tag}: venue_key '#{p['venue_key']}' not in #{VENUE_KEYS.join(', ')}") unless VENUE_KEYS.include?(p["venue_key"])
    err("#{tag}: type '#{p['type']}' not in #{TYPES.join(' / ')}") unless TYPES.include?(p["type"])
    err("#{tag}: 'selected' must be true or false") unless [true, false].include?(p["selected"])
    if p["year"].is_a?(Integer)
      err("#{tag}: year #{p['year']} is newer than the entry above (#{prev_year})") if prev_year && p["year"] > prev_year
      prev_year = p["year"]
    else
      err("#{tag}: 'year' must be an integer")
    end
    if nonempty_string?(p["tldr"]) && p["tldr"].scan(/[.!?](?=\s|\z)/).size != 1
      err("#{tag}: tldr must be exactly one sentence ending in . ! or ?")
    end
    links = p["links"]
    if links.is_a?(Hash) && !links.empty?
      links.each do |k, v|
        err("#{tag}: unknown link key '#{k}' (allowed: #{LINK_KEYS.join(', ')})") unless LINK_KEYS.include?(k)
        err("#{tag}: link '#{k}' must start with https://") unless v.is_a?(String) && v.start_with?("https://")
      end
    else
      err("#{tag}: 'links' must be a non-empty mapping")
    end
    err("#{tag}: 'award' must be a non-empty string when present") if p.key?("award") && !nonempty_string?(p["award"])
    if p["new"]
      new_flags += 1
      err("#{tag}: the 'new' entry must have a thumb") unless p["thumb"]
    end
    next unless p["thumb"]

    path = File.join(ROOT, "assets", "img", "pubs", p["thumb"].to_s)
    if File.exist?(path)
      w = image_width(path)
      err("#{tag}: thumb is #{w}px wide (max #{MAX_W})") if w.zero? || w > MAX_W
      err("#{tag}: thumb is #{File.size(path)} bytes (max #{MAX_BYTES})") if File.size(path) > MAX_BYTES
    else
      err("#{tag}: thumb #{p['thumb']} not found in assets/img/pubs/")
    end
  end
  err("publications.yml: #{new_flags} entries have new: true (max 1)") if new_flags > 1
  err("publications.yml: #{pubs.size} entries, expected #{opts[:total]}") if opts[:total] && pubs.size != opts[:total]
  selected = pubs.count { |p| p.is_a?(Hash) && p["selected"] == true }
  err("publications.yml: #{selected} selected, expected #{opts[:selected]}") if opts[:selected] && selected != opts[:selected]
end

# ---------- news ----------
news = load_data("news")
if news
  if news.is_a?(Array) && !news.empty?
    new_count = 0
    news.each_with_index do |n, i|
      unless n.is_a?(Hash)
        err("news[#{i}]: not a mapping")
        next
      end
      d = n["date"]
      unless d.is_a?(String) && d.match?(/\A\d{4}(-(0[1-9]|1[0-2]))?\z/)
        err("news[#{i}]: date must be a quoted string \"YYYY\" or \"YYYY-MM\" (got #{d.inspect})")
      end
      err("news[#{i}]: 'emoji' missing") unless nonempty_string?(n["emoji"])
      err("news[#{i}]: 'html' missing") unless nonempty_string?(n["html"])
      err("news[#{i}]: 'older' must be true or false") if n.key?("older") && ![true, false].include?(n["older"])
      new_count += 1 if n["new"]
    end
    err("news.yml: #{new_count} items have new: true (max 1)") if new_count > 1
    years = news.map { |n| n.is_a?(Hash) ? n["date"].to_s[0, 4] : "" }
    err("news.yml: items must be ordered newest year first") unless years.each_cons(2).all? { |a, b| a >= b }
  else
    err("news.yml: must be a non-empty list")
  end
end

# ---------- profile ----------
prof = load_data("profile")
if prof.is_a?(Hash)
  %w[name name_zh role org location email scholar_url].each { |k| err("profile.yml: '#{k}' missing") unless nonempty_string?(prof[k]) }
  unless prof["pinyin"].is_a?(Array) && prof["pinyin"].size == prof["name_zh"].to_s.chars.size
    err("profile.yml: pinyin must have one syllable per character of name_zh")
  end
  err("profile.yml: bio must be a non-empty list of HTML strings") unless prof["bio"].is_a?(Array) && !prof["bio"].empty?
  chips = prof["chips"].is_a?(Array) ? prof["chips"] : []
  err("profile.yml: chips missing") if chips.empty?
  chips.each_with_index do |c, i|
    unless c.is_a?(Hash) && nonempty_string?(c["label"]) && nonempty_string?(c["href"])
      err("profile.yml chips[#{i}]: needs label and href")
      next
    end
    err("profile.yml chips[#{i}]: #{c['href']} not found") if c["href"].start_with?("/") && !File.exist?(File.join(ROOT, c["href"]))
  end
  interests = prof["interests"].is_a?(Array) ? prof["interests"] : []
  err("profile.yml: interests missing") if interests.empty? || !interests.all? { |c| c.is_a?(Hash) && nonempty_string?(c["label"]) }
  sc = prof["scholar"]
  unless sc.is_a?(Hash) && sc["citations"].is_a?(Integer) && sc["h_index"].is_a?(Integer) && sc["updated"].is_a?(Date)
    err("profile.yml: scholar needs integer citations, integer h_index and an unquoted date 'updated'")
  end
  (chips + interests).each do |c|
    next unless c.is_a?(Hash) && c["icon"]

    err("profile.yml: icon '#{c['icon']}' has no _includes/icons/#{c['icon']}.svg") unless File.exist?(File.join(ROOT, "_includes", "icons", "#{c['icon']}.svg"))
  end
elsif prof
  err("profile.yml: must be a mapping")
end

# ---------- simple lists ----------
{
  "highlights" => %w[emoji bold rest], "education" => %w[institution logo degree dates],
  "experience" => %w[institution logo role dates], "awards" => %w[emoji title year],
  "service" => %w[label text], "teaching" => %w[html]
}.each do |name, keys|
  list = load_data(name)
  next unless list

  unless list.is_a?(Array) && !list.empty?
    err("#{name}.yml: must be a non-empty list")
    next
  end
  list.each_with_index do |item, i|
    keys.each { |k| err("#{name}[#{i}]: '#{k}' missing") unless item.is_a?(Hash) && nonempty_string?(item[k]) }
    next unless item.is_a?(Hash) && item["logo"]

    err("#{name}[#{i}]: logo #{item['logo']} not in assets/img/logos/") unless File.exist?(File.join(ROOT, "assets", "img", "logos", item["logo"]))
  end
end

if ERRORS.empty?
  puts "DATA OK"
else
  ERRORS.each { |e| puts "ERROR #{e}" }
  puts "#{ERRORS.size} problem(s)"
  exit 1
end
```

- [ ] **Step 2: Write the checker's self-test and the broken fixture**

`tools/test/check-data.test.sh`:

```bash
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
```

Run: `chmod +x tools/test/check-data.test.sh`

`tools/test/fixtures/bad/_data/publications.yml`:

```yaml
- title: Broken A
  authors: [Zhiyuan Li]
  venue: X 2024
  venue_key: icmlx
  type: Talk
  year: 2024
  selected: true
  new: true
  thumb: nope.webp
  tldr: "First sentence. Second sentence."
  links: {paper: "http://example.org/a"}
- title: Broken B
  authors: [Zhiyuan Li]
  venue: ICML 2025
  venue_key: icml
  type: Conference
  year: 2025
  selected: false
  new: true
  thumb: nope.webp
  tldr: "Fine."
  links: {paper: "https://example.org/b"}
```

`tools/test/fixtures/bad/_data/news.yml`:

```yaml
- {date: "2026-9", emoji: "🎉", html: "x", new: true}
- {date: "2025-05", emoji: "🎉", html: "y", new: true}
```

`tools/test/fixtures/bad/_data/profile.yml`:

```yaml
name: Zhiyuan Li
name_zh: 李志圆
pinyin: [Li]
role: Postdoctoral Researcher
org: Aalto
location: Espoo
email: x@example.org
scholar_url: https://example.org
bio: ["x"]
chips: [{label: CV, href: /nope.pdf}]
interests: [{label: RL}]
scholar: {citations: 1, h_index: 1, updated: 2026-09-30}
```

`tools/test/fixtures/bad/expected-errors.txt`:

```
venue_key 'icmlx'
type 'Talk'
must start with https://
entries have new: true (max 1)
tldr must be exactly one sentence
is newer than the entry above
thumb nope.webp not found
date must be a quoted string
items have new: true (max 1)
pinyin must have one syllable per character
/nope.pdf not found
highlights.yml: missing
```

- [ ] **Step 3: Run the self-test to verify it fails**

Run: `tools/test/check-data.test.sh`
Expected: `FAIL real data:` followed by `ERROR publications.yml: missing` and the other missing files. All fixture lines print `PASS caught: …`, because the checker already catches the broken fixture. Exit 1.

- [ ] **Step 4: Write the icons**

Each file is one line. The `class="ico"` lets CSS color the interest icons.

`_includes/icons/email.svg`:
```html
<svg class="ico" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="4"/><path d="M16 8v5a3 3 0 0 0 6 0v-1a10 10 0 1 0-4 8"/></svg>
```
`_includes/icons/scholar.svg`:
```html
<svg class="ico" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m2 9.5 10-5 10 5-10 5z"/><path d="M6 11.5v4.8c3.3 2.3 8.7 2.3 12 0v-4.8"/><path d="M22 9.5v5"/></svg>
```
`_includes/icons/github.svg`:
```html
<svg class="ico" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4"/><path d="M9 18c-4.51 2-5-2-7-2"/></svg>
```
`_includes/icons/orcid.svg`:
```html
<svg class="ico" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9.5"/><path d="M8.5 10.5V16"/><path d="M8.5 7.8v.01"/><path d="M11.5 16v-5.5h1.8a2.75 2.75 0 0 1 0 5.5z"/></svg>
```
`_includes/icons/doc.svg`:
```html
<svg class="ico" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5"/><path d="M9 13h6M9 17h4"/></svg>
```
`_includes/icons/agents.svg`:
```html
<svg class="ico" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="5" r="2.2"/><circle cx="5" cy="18.5" r="2.2"/><circle cx="19" cy="18.5" r="2.2"/><path d="M10.9 7 6.1 16.5M13.1 7l4.8 9.5M7.2 18.5h9.6"/></svg>
```
`_includes/icons/loop.svg`:
```html
<svg class="ico" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 11.5A8 8 0 0 0 5.8 7"/><path d="M5 3.5v4h4"/><path d="M4 12.5A8 8 0 0 0 18.2 17"/><path d="M19 20.5v-4h-4"/></svg>
```
`_includes/icons/robot.svg`:
```html
<svg class="ico" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="8" width="14" height="11" rx="3"/><path d="M12 4.5V8"/><circle cx="12" cy="3.5" r="1"/><path d="M9.5 13v.5M14.5 13v.5"/><path d="M2.5 12.5v3M21.5 12.5v3"/></svg>
```
`_includes/icons/layers.svg`:
```html
<svg class="ico" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m12 3 9 4.5-9 4.5-9-4.5z"/><path d="m3 12 9 4.5 9-4.5"/><path d="m3 16.5 9 4.5 9-4.5"/></svg>
```
`_includes/icons/arrow.svg`:
```html
<svg class="ico" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m13 6 6 6-6 6"/></svg>
```

- [ ] **Step 5: Write the data files**

`_data/profile.yml`:

```yaml
name: Zhiyuan Li
name_zh: 李志圆
pinyin: [Lǐ, Zhì, Yuán]
role: Postdoctoral Researcher
org: Aalto Robot Learning Lab, Aalto University
location: Espoo, Finland
email: zhiyuan.li@aalto.fi
scholar_url: https://scholar.google.com/citations?user=1GYbhX0AAAAJ
bio:
  - >-
    I am a postdoctoral researcher at the <a href="https://rl.aalto.fi/">Aalto Robot Learning Lab</a>,
    Aalto University, working with Prof. <a href="https://scholar.google.com/citations?user=-2fJStwAAAAJ">Joni Pajarinen</a>.
    I study how learning agents coordinate — with each other and with the physical world: multi-agent
    reinforcement learning, object-centric representations of video, and transfer from human video to robot embodiments.
  - >-
    I received my Ph.D. in Computer Science and Technology from the University of Electronic Science and
    Technology of China (2024) and my B.S. from North China Electric Power University (2019). During my Ph.D.
    I spent a year at Aalto as a CSC-funded visiting researcher.
chips:
  - {icon: email, label: "zhiyuan.li(at)aalto.fi", href: "mailto:zhiyuan.li@aalto.fi", mono: true}
  - {icon: scholar, label: Google Scholar, href: "https://scholar.google.com/citations?user=1GYbhX0AAAAJ"}
  - {icon: github, label: GitHub, href: "https://github.com/LiZhYun"}
  - {icon: orcid, label: ORCID, href: "https://orcid.org/0000-0002-1804-3485"}
  - {icon: doc, label: CV, href: /assets/pdf/Li_Zhiyuan_CV.pdf}
  - {icon: doc, label: 中文简历, href: /assets/pdf/Li_Zhiyuan_CV_zh.pdf, lang: zh}
interests:
  - {icon: agents, label: Multi-Agent Systems}
  - {icon: loop, label: Reinforcement Learning}
  - {icon: robot, label: Robotics}
  - {icon: layers, label: Foundation Models}
scholar:
  citations: 91
  h_index: 6
  updated: 2026-09-30
```

`_data/highlights.yml`:

```yaml
- {emoji: "🧑‍⚖️", bold: Area Chair, rest: ICLR 2027}
- {emoji: "🎤", bold: Oral, rest: AAAI 2025}
- {emoji: "📄", bold: 2 papers, rest: NeurIPS 2026}
- {emoji: "🧑‍🏫", bold: Head TA, rest: "Aalto RL course (243 students)"}
```

`_data/news.yml`:

```yaml
# Newest first. date is a quoted "YYYY-MM" or "YYYY". At most one item has new: true.
# Items with older: true stay hidden until "Show older" is clicked.
- date: "2026-09"
  emoji: "🎉"
  new: true
  html: 'Two papers accepted to NeurIPS 2026: <a href="https://arxiv.org/abs/2609.37297">cross-skeleton motion retargeting</a>, and <a href="https://arxiv.org/abs/2602.02699">Sparsely Supervised Diffusion</a>.'
- date: "2026"
  emoji: "🧑‍⚖️"
  html: "Serving as Area Chair for ICLR 2027."
- date: "2026-05"
  emoji: "🎉"
  html: '<a href="https://proceedings.mlr.press/v306/li26js.html">Rethinking Temporal Consistency in Video Object-Centric Learning</a> accepted to ICML 2026.'
- date: "2026-05"
  emoji: "🎤"
  html: '<a href="https://arxiv.org/abs/2502.10148">COMPASS</a> accepted as a lightning talk at the SE@AAMAS 2026 workshop in Paphos, Cyprus.'
- date: "2025-05"
  emoji: "🎉"
  html: '<a href="https://proceedings.mlr.press/v267/zhao25o.html">Learning Progress Driven Multi-Agent Curriculum</a> accepted to ICML 2025.'
- date: "2024-12"
  emoji: "🏆"
  html: '<a href="https://doi.org/10.1609/aaai.v39i17.34048">AgentMixer</a> accepted to AAAI 2025 as an oral presentation.'
- date: "2024-08"
  emoji: "🏠"
  html: 'Joined the <a href="https://rl.aalto.fi/">Aalto Robot Learning Lab</a> as a postdoctoral researcher.'
- date: "2024-05"
  emoji: "🎉"
  older: true
  html: '<a href="https://proceedings.mlr.press/v235/zhao24v.html">Optimistic Multi-Agent Policy Gradient</a> accepted to ICML 2024.'
- date: "2024-01"
  emoji: "🎉"
  older: true
  html: '<a href="https://doi.org/10.1016/j.neunet.2024.106101">Coordination as Inference in MARL</a> accepted by Neural Networks.'
- date: "2023-12"
  emoji: "🎉"
  older: true
  html: '<a href="https://doi.org/10.1609/aaai.v38i12.29277">Backpropagation Through Agents</a> accepted to AAAI 2024.'
- date: "2022-11"
  emoji: "✈️"
  older: true
  html: "Began a one-year visit at the Aalto Robot Learning Lab."
- date: "2022-09"
  emoji: "🎉"
  older: true
  html: '<a href="https://doi.org/10.1109/TNSM.2022.3205900">OCRA</a> accepted by IEEE Transactions on Network and Service Management.'
```

`_data/publications.yml`:

```yaml
# Newest year first; list order is display order. Fields: spec §4.
# After adding or removing entries, update the counts in README.md ("Run the checks").

- title: "Why Cross-Skeleton Retargeting Is Non-Identifiable: Structural Limits of Generative Motion Models"
  authors: [Zhiyuan Li, Wenyan Yang, Pekka Marttinen, Joni Pajarinen]
  venue: NeurIPS 2026
  venue_key: neurips
  type: Conference
  year: 2026
  selected: true
  new: true
  thumb: retargeting.webp
  tldr: "Under standard generative objectives, sparse multi-body motion data cannot pin down which source-to-target map a cross-skeleton retargeting model learns, so the paper proposes Source-Instance Fidelity (SIF) to test whether generated motion actually follows its source clip."
  links:
    paper: https://arxiv.org/abs/2609.37297
    code: https://github.com/LiZhYun/NeurIPS2026-Cross-Skeleton-Retargeting
    project: https://cross-skeleton-retargeting.netlify.app/

- title: Sparsely Supervised Diffusion
  authors: [Wenshuai Zhao, Zhiyuan Li, Yi Zhao, Mohammad Hassan Vali, Martin Trapp, Joni Pajarinen, Juho Kannala, Arno Solin]
  venue: NeurIPS 2026
  venue_key: neurips
  type: Conference
  year: 2026
  selected: false
  thumb: sparsely-supervised-diffusion.webp
  tldr: "A simple masking strategy for diffusion training that targets spatially inconsistent generation: masking up to 98% of pixels keeps FID competitive, avoids training instability on small datasets and reduces memorization."
  links:
    paper: https://arxiv.org/abs/2602.02699
    project: https://sites.google.com/view/sparsely-supervised-diffusion/home

- title: "Rethinking Temporal Consistency in Video Object-Centric Learning: From Prediction to Correspondence"
  authors: [Zhiyuan Li, Rongzhen Zhao, Wenyan Yang, Wenshuai Zhao, Pekka Marttinen, Joni Pajarinen]
  venue: ICML 2026
  venue_key: icml
  type: Conference
  year: 2026
  selected: true
  thumb: rethinking-ocl.webp
  tldr: "Learned temporal predictors in video object-centric models mostly just keep slot indices stable, so seeding slots from saliency peaks in frozen DINOv2 features and Hungarian-matching them across frames does the same job with no learned temporal parameters."
  links:
    paper: https://proceedings.mlr.press/v306/li26js.html
    arxiv: https://arxiv.org/abs/2605.03650
    code: https://github.com/LiZhYun/ICML2026-RethinkingOCL
    project: https://magenta-sherbet-85b101.netlify.app/

- title: Closed-Loop Vision-Language Planning for Multi-Agent Coordination
  authors: [Zhiyuan Li, Wenshuai Zhao, Joni Pajarinen]
  venue: SE@AAMAS 2026
  venue_key: aamas
  type: Workshop
  year: 2026
  selected: false
  thumb: compass.webp
  tldr: "Each agent plans with a vision-language model in a closed loop, writes and reuses code skills, and shares observations through multi-hop communication; evaluated on SMACv2."
  links:
    paper: https://arxiv.org/abs/2502.10148
    code: https://github.com/LiZhYun/COMPASS-SE-AAMAS
    project: https://lizhyun.github.io/COMPASS/

- title: "Bridging the Embodiment Gap: Disentangled Cross-Embodiment Video Editing"
  authors: [Zhiyuan Li, Wenyan Yang, Wenshuai Zhao, Yue Ma, Yuanpeng Tu, Pekka Marttinen, Joni Pajarinen]
  venue: arXiv 2026
  venue_key: arxiv
  type: Preprint
  year: 2026
  selected: true
  thumb: egoxedit.webp
  tldr: "Turns an egocentric human manipulation video into a robot demonstration video by separating task and embodiment codes that condition a frozen video diffusion model."
  links:
    paper: https://arxiv.org/abs/2605.03637
    code: https://github.com/LiZhYun/EgoXEdit

- title: Do We Really Need the Default Recipe for Video Object-Centric Learning?
  authors: [Zhiyuan Li, Rongzhen Zhao, Wenyan Yang, Wenshuai Zhao, Arno Solin, Juho Kannala, Pekka Marttinen, Joni Pajarinen]
  venue: IEEE TPAMI
  venue_key: tpami
  type: Under review
  year: 2026
  selected: false
  thumb: default-recipe.webp
  tldr: "A controlled study showing that neither a learned temporal predictor nor a frozen backbone is always necessary for video object-centric learning: what matters is how object identity is carried across frames, and whether an adapted encoder stays tied to a frozen pretrained feature target."
  links:
    code: https://github.com/LiZhYun/ICML2026-RethinkingOCL

- title: Learning Progress Driven Multi-Agent Curriculum
  authors: [Wenshuai Zhao, Zhiyuan Li, Joni Pajarinen]
  venue: ICML 2025
  venue_key: icml
  type: Conference
  year: 2025
  selected: false
  thumb: lpmc.webp
  tldr: "Uses the number of agents as a curriculum variable and advances the curriculum with a TD-error-based learning-progress measure, outperforming state-of-the-art baselines on three sparse-reward MARL benchmarks."
  links:
    paper: https://proceedings.mlr.press/v267/zhao25o.html
    arxiv: https://arxiv.org/abs/2205.10016
    code: https://github.com/wenshuaizhao/spmarl
    project: https://wenshuaizhao.github.io/spmarl/

- title: "AgentMixer: Multi-Agent Correlated Policy Factorization"
  authors: [Zhiyuan Li, Wenshuai Zhao, Lijun Wu, Joni Pajarinen]
  venue: AAAI 2025
  venue_key: aaai
  type: Conference
  award: Oral
  year: 2025
  selected: true
  thumb: agentmixer.webp
  tldr: "A centralized joint policy correlates agents' actions, while a mode-consistency constraint keeps it executable by decentralized, partially observing agents."
  links:
    paper: https://doi.org/10.1609/aaai.v39i17.34048
    arxiv: https://arxiv.org/abs/2401.08728

- title: Adaptive graph attention networks with interactive learning for attributed graph clustering
  authors: [Weiwei Duan, Luping Ji, Lijun Wu, Qi Deng, Zhiyuan Li]
  venue: EAAI 2025
  venue_key: eaai
  type: Journal
  year: 2025
  selected: false
  tldr: "Adaptive graph attention networks with interactive learning (AGAT-IL) for clustering the nodes of attributed graphs."
  links:
    paper: https://doi.org/10.1016/j.engappai.2025.111574
    code: https://github.com/MrDec/AGAT-IL

- title: Multi-agent neighborhood coordinated and holistic optimized actor-critic framework for adaptive traffic signal control
  authors: [Qi Deng, Lijun Wu, Zhiyuan Li, Kaile Su, Wei Wu, Weiwei Duan]
  venue: Applied Intelligence 2025
  venue_key: apin
  type: Journal
  year: 2025
  selected: false
  tldr: "NcHo-AC frames adaptive traffic signal control as a competitive-cooperative game and combines neighborhood coordination with a mean-field approximation, so multi-agent actor-critic learning scales to large traffic networks."
  links:
    paper: https://doi.org/10.1007/s10489-025-06758-x
    oa: https://research.aalto.fi/en/publications/multi-agent-neighborhood-coordinated-and-holistic-optimized-actor/

- title: Optimistic Multi-Agent Policy Gradient
  authors: [Wenshuai Zhao, Yi Zhao, Zhiyuan Li, Juho Kannala, Joni Pajarinen]
  venue: ICML 2024
  venue_key: icml
  type: Conference
  year: 2024
  selected: false
  thumb: optimappo.webp
  tldr: "Clipping the advantage to remove negative values gives optimistic multi-agent policy-gradient updates that counter relative overgeneralization, outperforming strong baselines on 13 of 19 tasks and matching them on the rest."
  links:
    paper: https://proceedings.mlr.press/v235/zhao24v.html
    arxiv: https://arxiv.org/abs/2311.01953
    code: https://github.com/wenshuaizhao/optimappo
    project: https://wenshuaizhao.github.io/optimappo/

- title: Backpropagation Through Agents
  authors: [Zhiyuan Li, Wenshuai Zhao, Lijun Wu, Joni Pajarinen]
  venue: AAAI 2024
  venue_key: aaai
  type: Conference
  year: 2024
  selected: true
  thumb: bpta.webp
  tldr: "Later agents in an auto-regressive multi-agent policy send gradients back to earlier agents through their actions."
  links:
    paper: https://doi.org/10.1609/aaai.v38i12.29277
    arxiv: https://arxiv.org/abs/2401.12574
    code: https://github.com/LiZhYun/BackPropagationThroughAgents

- title: Coordination as Inference in Multi-Agent Reinforcement Learning
  authors: [Zhiyuan Li, Lijun Wu, Kaile Su, Wei Wu, Yulin Jing, Tong Wu, Weiwei Duan, Xiaofeng Yue, Xiyi Tong, Yizhou Han]
  venue: Neural Networks 2024
  venue_key: nn
  type: Journal
  year: 2024
  selected: true
  thumb: dms.webp
  tldr: "Independent learners infer teammates' intentions from observed actions and choose whom to coordinate with — no centralized critic, no communication."
  links:
    paper: https://doi.org/10.1016/j.neunet.2024.106101
    code: https://github.com/LiZhYun/DMS

- title: Online Coordinated NFV Resource Allocation via Novel Machine Learning Techniques
  authors: [Zhiyuan Li, Lijun Wu, Xiangyun Zeng, Xiaofeng Yue, Yulin Jing, Wei Wu, Kaile Su]
  venue: IEEE TNSM 2023
  venue_key: tnsm
  type: Journal
  year: 2023
  selected: false
  thumb: ocra.webp
  tldr: "A parallel multi-agent deep RL framework that performs all three stages of NFV resource allocation jointly and online by generating an embedding subgraph per request."
  links:
    paper: https://doi.org/10.1109/TNSM.2022.3205900
```

(If the owner rejected a co-author thumbnail in Task 2 Step 6, delete that paper's `thumb:` line.)

`_data/education.yml`:

```yaml
- institution: University of Electronic Science and Technology of China
  logo: uestc.png
  degree: Ph.D. in Computer Science and Technology
  dates: Sep 2019 – Jul 2024
- institution: North China Electric Power University
  logo: ncepu.png
  degree: B.S. in Computer Science and Technology
  dates: Sep 2015 – Jul 2019
```

`_data/experience.yml`:

```yaml
- institution: Aalto Robot Learning Lab, Aalto University
  logo: aalto.png
  role: Postdoctoral Researcher
  note: "Host: Prof. Joni Pajarinen"
  dates: Aug 2024 – Present
- institution: Aalto University
  logo: aalto.png
  role: Visiting Ph.D. Researcher (CSC-funded)
  dates: Nov 2022 – Dec 2023
```

`_data/awards.yml`:

```yaml
- {emoji: "🏅", title: "China Scholarship Council (CSC) Scholarship", year: "2022"}
- {emoji: "🎖️", title: "Academic Scholarship", org: UESTC, year: "2019–2022"}
- {emoji: "🏅", title: "Honorable Mention", org: "Mathematical Contest in Modeling (MCM)", year: "2017"}
```

`_data/service.yml`:

```yaml
- {label: Area Chair, text: ICLR 2027}
- {label: Reviewer, text: "NeurIPS, ICML, ICLR, AAAI, ECCV, AAMAS"}
```

`_data/teaching.yml`:

```yaml
- html: "Main teaching assistant, <strong>ELEC-E8125 Reinforcement Learning</strong>, Aalto University — 243 students; coordinated a 12-person TA team."
```

- [ ] **Step 6: Run the self-test to verify it passes**

Run: `tools/test/check-data.test.sh`
Expected: `PASS real data` and 12 `PASS caught: …` lines. Exit 0.

- [ ] **Step 7: Commit**

```bash
git add _data _includes/icons tools/check-data.rb tools/test
git commit -m "feat: add site content data files and data validation gate

Co-Authored-By: <attribution line 1>
Claude-Session: <attribution line 2>"
```

---

### Task 4: Page templates, light stylesheet and no-JS browser gate

**Files:**
- Replace: `_layouts/default.html`, `_layouts/home.html`
- Create:
  - `_includes/chip.html`, `_includes/timeline-row.html`, `_includes/news-row.html`, `_includes/pub-row.html`
  - `assets/css/site.css`
  - `tools/package.json`, `tools/browser.mjs`

**Interfaces:**
- Consumes: the Task 3 data shapes and Task 2 asset paths.
- Produces the DOM contract that `site.js` (Task 5) and `tools/browser.mjs` rely on:
  - Publications:
    - `section#publications[data-pubs]` is the card.
    - `[data-pub-title]` is the text node "Selected Publications".
    - `[data-pub-filter]` is the button group, rendered `hidden`. Its buttons are `[data-filter="selected"]` (`aria-pressed="true"`) and `[data-filter="all"]`.
    - `article.pub` is one row, with `data-selected="true|false"` and `hidden` when not selected.
    - `h3.pub-year` is a year heading, rendered `hidden`.
  - News:
    - `.n-item` is one news row; older rows are `[data-older][hidden]`.
    - A `.yr-grp` whose items are all older is also `[data-older][hidden]`.
    - `[data-show-older]` is the button, rendered `hidden`.
  - Theme: the `[data-theme-toggle]` button is rendered `hidden`, holding `.emo` text 🌙.
  - Decoration: decorative background elements carry `data-deco`.
- `node tools/browser.mjs <static|behavior|screens|weight|all>` prints `PASS`/`FAIL` lines, then `BROWSER OK` and exit 0, or exit 1.

- [ ] **Step 1: Install the browser driver and write `tools/browser.mjs`**

`tools/package.json`:

```json
{
  "name": "lizhyun-site-tools",
  "private": true,
  "type": "module",
  "devDependencies": {
    "playwright-core": "1.63.0"
  }
}
```

Run: `(cd tools && npm install)`. It creates `tools/package-lock.json`; commit it. `node_modules/` is gitignored.

`tools/browser.mjs`:

```js
// Browser gates for the built site. Serves _site on a local port and drives the
// system Chrome through playwright-core (no browser download).
// Usage: node tools/browser.mjs <static|behavior|screens|weight|all>
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright-core';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const SITE = path.join(ROOT, '_site');
const OUT = path.join(ROOT, 'tools', 'out');
const CHROME = process.env.CHROME || '/usr/bin/google-chrome';
const VIEWPORTS = [{ width: 1440, height: 900 }, { width: 390, height: 844 }];
const SCHEMES = ['light', 'dark'];
const DARK_GROUND = 'rgb(15, 19, 24)';
const TYPES = {
  '.html': 'text/html; charset=utf-8', '.css': 'text/css', '.js': 'text/javascript',
  '.png': 'image/png', '.webp': 'image/webp', '.jpg': 'image/jpeg', '.ico': 'image/x-icon',
  '.pdf': 'application/pdf', '.xml': 'application/xml', '.txt': 'text/plain', '.svg': 'image/svg+xml',
};

let failures = 0;
function check(ok, msg) {
  console.log(`${ok ? 'PASS' : 'FAIL'} ${msg}`);
  if (!ok) failures += 1;
}

function serve() {
  const server = http.createServer((req, res) => {
    const urlPath = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
    let file = path.join(SITE, urlPath);
    if (!file.startsWith(SITE)) { res.writeHead(403); res.end(); return; }
    if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, 'index.html');
    if (!fs.existsSync(file)) {
      const nf = path.join(SITE, '404.html');
      res.writeHead(404, { 'content-type': TYPES['.html'] });
      res.end(fs.existsSync(nf) ? fs.readFileSync(nf) : 'Not found');
      return;
    }
    res.writeHead(200, { 'content-type': TYPES[path.extname(file)] || 'application/octet-stream' });
    fs.createReadStream(file).pipe(res);
  });
  return new Promise((resolve) => server.listen(0, '127.0.0.1', () => resolve(server)));
}

function visibleCount(page, selector) {
  return page.$$eval(selector, (els) => els.filter((e) => e.getClientRects().length > 0).length);
}

function overflow(page) {
  return page.evaluate(() => {
    const vw = document.documentElement.clientWidth;
    const bad = [];
    if (document.documentElement.scrollWidth > vw) bad.push(`scrollWidth ${document.documentElement.scrollWidth} > ${vw}`);
    for (const el of document.querySelectorAll('body *')) {
      if (el.closest('[data-deco]')) continue;
      const r = el.getBoundingClientRect();
      if (r.width > 0 && r.right > vw + 1) bad.push(`${el.tagName.toLowerCase()}.${el.className} right=${Math.round(r.right)}`);
    }
    return bad.slice(0, 5);
  });
}

async function staticChecks(browser, base) {
  for (const vp of VIEWPORTS) {
    for (const scheme of SCHEMES) {
      const ctx = await browser.newContext({ viewport: vp, colorScheme: scheme, javaScriptEnabled: false });
      const page = await ctx.newPage();
      await page.goto(`${base}/`, { waitUntil: 'load' });
      const tag = `[no-JS ${vp.width} ${scheme}]`;
      check(await visibleCount(page, 'article.pub') === 6, `${tag} 6 selected papers visible`);
      check(await visibleCount(page, '.pub-year') === 0, `${tag} no year headings in the Selected view`);
      check(await visibleCount(page, '.n-item') === 7, `${tag} 7 current news items visible`);
      for (const sel of ['[data-pub-filter]', '[data-show-older]', '[data-theme-toggle]']) {
        check(await visibleCount(page, sel) === 0, `${tag} ${sel} hidden without JS`);
      }
      check((await page.textContent('h1')).includes('Zhiyuan Li'), `${tag} h1 names Zhiyuan Li`);
      const broken = await page.$$eval('img:not([loading="lazy"])', (imgs) =>
        imgs.filter((i) => !i.complete || i.naturalWidth === 0).map((i) => i.getAttribute('src')));
      check(broken.length === 0, `${tag} eager images load ${broken.join(' ')}`);
      const over = await overflow(page);
      check(over.length === 0, `${tag} no horizontal overflow ${over.join('; ')}`);
      check(!(await page.content()).includes('†'), `${tag} no corresponding-author marks`);
      await ctx.close();
    }
  }
}

async function behaviorChecks(browser, base) {
  for (const vp of VIEWPORTS) {
    const ctx = await browser.newContext({ viewport: vp, colorScheme: 'light' });
    const page = await ctx.newPage();
    await page.goto(`${base}/`, { waitUntil: 'load' });
    const tag = `[JS ${vp.width}]`;
    check(await visibleCount(page, '[data-pub-filter]') === 1, `${tag} filter shown with JS`);
    check(await visibleCount(page, 'article.pub') === 6, `${tag} starts with 6 papers`);
    await page.click('[data-filter="all"]');
    check(await visibleCount(page, 'article.pub') === 14, `${tag} All shows 14 papers`);
    check(await visibleCount(page, '.pub-year') === 4, `${tag} All shows 4 year headings`);
    check((await page.textContent('[data-pub-title]')).trim() === 'Publications', `${tag} title becomes Publications`);
    check(await page.getAttribute('[data-filter="all"]', 'aria-pressed') === 'true', `${tag} All is pressed`);
    await page.click('[data-filter="selected"]');
    check(await visibleCount(page, 'article.pub') === 6, `${tag} Selected returns to 6`);
    check((await page.textContent('[data-pub-title]')).trim() === 'Selected Publications', `${tag} title back to Selected Publications`);
    check(await visibleCount(page, '[data-show-older]') === 1, `${tag} Show older shown with JS`);
    await page.click('[data-show-older]');
    check(await visibleCount(page, '.n-item') === 12, `${tag} Show older reveals all 12 items`);
    check(await page.$('[data-show-older]') === null, `${tag} Show older button removed`);
    const ground = () => page.evaluate(() => getComputedStyle(document.body).backgroundColor);
    const lightGround = await ground();
    check(await visibleCount(page, '[data-theme-toggle]') === 1, `${tag} theme button shown with JS`);
    await page.click('[data-theme-toggle]');
    check(await page.getAttribute('html', 'data-theme') === 'dark', `${tag} toggle sets data-theme=dark`);
    check(await ground() === DARK_GROUND && lightGround !== DARK_GROUND, `${tag} ground switches to dark`);
    await page.reload({ waitUntil: 'load' });
    check(await page.getAttribute('html', 'data-theme') === 'dark', `${tag} theme persists after reload`);
    check(await page.getAttribute('[data-theme-toggle]', 'aria-label') === 'Switch to light theme', `${tag} button offers the light theme`);
    const over = await overflow(page);
    check(over.length === 0, `${tag} no horizontal overflow in dark ${over.join('; ')}`);
    await ctx.close();
  }
  const ctx = await browser.newContext({ colorScheme: 'dark', javaScriptEnabled: false });
  const page = await ctx.newPage();
  await page.goto(`${base}/`, { waitUntil: 'load' });
  check(await page.evaluate(() => getComputedStyle(document.body).backgroundColor) === DARK_GROUND,
    '[no-JS, OS dark] page uses the dark ground');
  await ctx.close();
}

async function screens(browser, base) {
  fs.mkdirSync(OUT, { recursive: true });
  for (const vp of VIEWPORTS) {
    for (const scheme of SCHEMES) {
      const ctx = await browser.newContext({ viewport: vp, colorScheme: scheme });
      const page = await ctx.newPage();
      await page.goto(`${base}/`, { waitUntil: 'load' });
      await page.evaluate(() => document.querySelectorAll('img[loading="lazy"]').forEach((i) => { i.loading = 'eager'; }));
      await page.waitForTimeout(1000);
      const file = path.join(OUT, `home-${vp.width}-${scheme}.png`);
      await page.screenshot({ path: file, fullPage: true });
      console.log(`SHOT ${file}`);
      await ctx.close();
    }
  }
}

async function weight(browser, base) {
  const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await ctx.newPage();
  const cdp = await ctx.newCDPSession(page);
  await cdp.send('Network.enable');
  await cdp.send('Network.setCacheDisabled', { cacheDisabled: true });
  let bytes = 0;
  cdp.on('Network.loadingFinished', (e) => { bytes += e.encodedDataLength; });
  await page.goto(`${base}/`, { waitUntil: 'load' });
  await page.waitForTimeout(2000);
  const mb = bytes / (1024 * 1024);
  check(mb <= 1.2, `first-load weight ${mb.toFixed(2)} MB (max 1.2 MB, uncompressed local server)`);
  await ctx.close();
}

const MODES = { static: staticChecks, behavior: behaviorChecks, screens, weight };
const mode = process.argv[2] || 'all';
const run = mode === 'all' ? Object.keys(MODES) : [mode];
if (!fs.existsSync(path.join(SITE, 'index.html'))) {
  console.error('Build the site first: tools/build.sh');
  process.exit(2);
}
const server = await serve();
const base = `http://127.0.0.1:${server.address().port}`;
const browser = await chromium.launch({ executablePath: CHROME, headless: true });
try {
  for (const m of run) {
    if (!MODES[m]) throw new Error(`unknown mode ${m}`);
    console.log(`== ${m}`);
    await MODES[m](browser, base);
  }
} finally {
  await browser.close();
  server.close();
}
if (failures) {
  console.log(`${failures} check(s) failed`);
  process.exit(1);
}
console.log('BROWSER OK');
```

- [ ] **Step 2: Run the static gate to verify it fails**

Run: `tools/build.sh >/dev/null && node tools/browser.mjs static`
Expected: `FAIL … 6 selected papers visible` (the skeleton has none) and more failures. Exit 1.

- [ ] **Step 3: Write the layouts and includes**

`_layouts/default.html`:

```html
<!doctype html>
<html lang="{{ site.lang }}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script>
  (function () {
    try {
      var t = localStorage.getItem('theme');
      if (t === 'light' || t === 'dark') document.documentElement.setAttribute('data-theme', t);
    } catch (e) {}
  })();
</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,300;0,400;0,700;1,400&amp;family=JetBrains+Mono:wght@400&amp;display=swap">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400&amp;text=%E6%9D%8E%E5%BF%97%E5%9C%86%E4%B8%AD%E6%96%87%E7%AE%80%E5%8E%86&amp;display=swap">
<link rel="stylesheet" href="{{ '/assets/css/site.css' | relative_url }}">
<link rel="icon" type="image/png" sizes="32x32" href="{{ '/assets/img/favicon.png' | relative_url }}">
<link rel="apple-touch-icon" sizes="180x180" href="{{ '/assets/img/apple-touch-icon.png' | relative_url }}">
{% seo %}
</head>
<body>
<div class="page">
  <div class="bg-dots" data-deco aria-hidden="true"></div>
  <div class="glow glow-blue" data-deco aria-hidden="true"></div>
  <div class="glow glow-teal" data-deco aria-hidden="true"></div>

  <header class="nav">
    <div class="nav-in">
      <a class="brand" href="{{ '/' | relative_url }}">
        <span class="brand-en">{{ site.data.profile.name }}</span>
        <span class="brand-zh" lang="zh">{{ site.data.profile.name_zh }}</span>
      </a>
      <div class="nav-right">
        <nav class="nav-links" aria-label="Primary">
          <a class="nv nv-home" href="{{ '/' | relative_url }}"{% if page.url == "/" %} aria-current="page"{% endif %}>Home</a>
          <a class="nv" href="{{ '/#publications' | relative_url }}">Publications</a>
        </nav>
        <span class="nav-sep" aria-hidden="true"></span>
        <button type="button" class="theme-toggle" data-theme-toggle hidden aria-label="Switch to dark theme" title="Switch to dark theme"><span class="emo" aria-hidden="true">🌙</span></button>
      </div>
    </div>
  </header>

  <main>
{{ content }}
  </main>

  <footer class="footer">
    <em>Last updated: {{ site.time | date: "%b %Y" }}</em>
    <span>© {{ site.time | date: "%Y" }} {{ site.data.profile.name }}</span>
  </footer>
</div>
</body>
</html>
```

`_includes/chip.html`:

```html
{%- assign c = include.chip -%}
{%- capture chip_inner -%}
{%- if c.icon %}{% include icons/{{ c.icon }}.svg %}{% endif -%}
<span{% if c.mono %} class="mono"{% elsif c.lang == "zh" %} class="zh" lang="zh"{% endif %}>{{ c.label }}</span>
{%- endcapture -%}
{%- if c.href -%}
<a class="chip" href="{{ c.href | relative_url }}">{{ chip_inner }}</a>
{%- else -%}
<span class="chip chip-plain">{{ chip_inner }}</span>
{%- endif -%}
```

`_includes/timeline-row.html`:

```html
<div class="org">
  <span class="logo"><img src="{{ '/assets/img/logos/' | append: include.logo | relative_url }}" alt="" width="30" height="30"></span>
  <div class="org-body">
    <span class="org-name">{{ include.org }}</span>
    <div class="org-meta"><span>{{ include.role }}{% if include.note %} · {{ include.note }}{% endif %}</span><em>{{ include.dates }}</em></div>
  </div>
</div>
```

`_includes/news-row.html`:

```html
{%- assign n = include.item -%}
{%- assign month = n.date | slice: 5, 2 -%}
<li class="n-item"{% if n.older %} data-older hidden{% endif %}>
  <span class="emo n-emo" aria-hidden="true">{{ n.emoji }}</span>
  <span class="n-text">{{ n.html }}{% if n.new %}<span class="new-pill">NEW</span>{% endif %}</span>
  <em class="n-date">{% if month != "" %}{% assign mi = month | plus: 0 | minus: 1 %}{{ include.months[mi] }} {{ n.date | slice: 0, 4 }}{% else %}{{ n.date }}{% endif %}</em>
</li>
```

`_includes/pub-row.html`:

```html
{%- assign pub = include.pub -%}
{%- assign l = pub.links -%}
{%- if l.paper %}{% assign primary = l.paper %}{% elsif l.arxiv %}{% assign primary = l.arxiv %}{% elsif l.project %}{% assign primary = l.project %}{% else %}{% assign primary = l.code %}{% endif -%}
{%- if l.project %}{% assign thumb_href = l.project %}{% else %}{% assign thumb_href = primary %}{% endif -%}
<article class="pub{% unless pub.thumb %} pub-compact{% endunless %}" data-selected="{{ pub.selected }}"{% unless pub.selected %} hidden{% endunless %}>
  {%- if pub.thumb %}
  <div class="thumb-wrap">
    <a class="thumb" href="{{ thumb_href }}" tabindex="-1" aria-hidden="true"><img src="{{ '/assets/img/pubs/' | append: pub.thumb | relative_url }}" alt="" width="400" height="268" loading="lazy" decoding="async"></a>
    {%- if pub.new %}<span class="hot"><span class="emo" aria-hidden="true">🔥</span>New</span>{% endif %}
  </div>
  {%- endif %}
  <div class="pub-body">
    <h4 class="pub-title"><a class="tl" href="{{ primary }}">{{ pub.title }}</a></h4>
    <p class="authors">{% for a in pub.authors %}{% if a == "Zhiyuan Li" %}<strong>{{ a }}</strong>{% else %}{{ a }}{% endif %}{% unless forloop.last %}, {% endunless %}{% endfor %}</p>
    <div class="meta">
      <span class="venue v-{{ pub.venue_key }}">{{ pub.venue }}</span>
      <span class="type">{{ pub.type }}</span>
      {%- if pub.award %}<span class="oral"><span class="emo" aria-hidden="true">🏆</span>{{ pub.award }}</span>{% endif %}
    </div>
    <p class="tldr">{{ pub.tldr }}</p>
    <div class="links">
      {%- if l.paper %}<a class="btn" href="{{ l.paper }}"><span class="emo" aria-hidden="true">📄</span>Paper</a>{% endif -%}
      {%- if l.arxiv %}<a class="btn" href="{{ l.arxiv }}"><span class="emo" aria-hidden="true">📜</span>arXiv</a>{% endif -%}
      {%- if l.oa %}<a class="btn" href="{{ l.oa }}"><span class="emo" aria-hidden="true">📖</span>Open access</a>{% endif -%}
      {%- if l.code %}<a class="btn" href="{{ l.code }}"><span class="emo" aria-hidden="true">💻</span>Code</a>{% endif -%}
      {%- if l.project %}<a class="btn" href="{{ l.project }}"><span class="emo" aria-hidden="true">🌐</span>Project</a>{% endif -%}
    </div>
  </div>
</article>
```

`_layouts/home.html`:

```html
---
layout: default
---
{%- assign p = site.data.profile -%}
{%- assign zh_chars = p.name_zh | split: "" -%}
<section class="card hero" aria-labelledby="hero-name">
  <div class="hero-top">
    <div class="hero-text">
      <div class="hero-head">
        <h1 id="hero-name">
          <span>{{ p.name }}</span>
          <span class="zh-name" lang="zh"><ruby>{% for ch in zh_chars %}{{ ch }}<rt>{{ p.pinyin[forloop.index0] }}</rt>{% endfor %}</ruby></span>
        </h1>
        <div class="hero-sub">
          <span><span class="emo emo-lead" aria-hidden="true">🤖</span>{{ p.role }} @ {{ p.org }}</span>
          <span class="loc"><span class="emo emo-lead" aria-hidden="true">📍</span>{{ p.location }}</span>
        </div>
      </div>
      <div class="bio">
        {%- for para in p.bio %}
        <p>{{ para }}</p>
        {%- endfor %}
      </div>
    </div>
    <div class="avatar">
      <img src="{{ '/assets/img/avatar.png' | relative_url }}" alt="Avatar of {{ p.name }}" width="150" height="150">
    </div>
  </div>

  <div class="hero-boxes">
    <div class="box">
      <h2 class="box-title"><span class="emo" aria-hidden="true">📬</span><span>Social &amp; Contacts</span></h2>
      <div class="chips">
        {%- for c in p.chips %}
        {% include chip.html chip=c %}
        {%- endfor %}
      </div>
    </div>
    <div class="box">
      <h2 class="box-title"><span class="emo" aria-hidden="true">🔬</span><span>Research Interests</span></h2>
      <div class="chips">
        {%- for c in p.interests %}
        {% include chip.html chip=c %}
        {%- endfor %}
      </div>
    </div>
    <div class="box">
      <h2 class="box-title"><span class="emo" aria-hidden="true">✨</span><span>Highlights</span></h2>
      <div class="chips">
        {%- for h in site.data.highlights %}
        <span class="chip chip-hl"><span class="emo" aria-hidden="true">{{ h.emoji }}</span><span><strong>{{ h.bold }}</strong> <span class="dot-sep" aria-hidden="true">·</span> {{ h.rest }}</span></span>
        {%- endfor %}
      </div>
    </div>
  </div>
</section>

<section class="card cols" aria-label="Education, experience, honors, service and teaching">
  <div class="col">
    <div class="blk">
      <h2 class="sec"><span class="emo" aria-hidden="true">🎓</span><span>Education</span></h2>
      <div class="orgs">
        {%- for o in site.data.education %}
        {% include timeline-row.html org=o.institution logo=o.logo role=o.degree dates=o.dates %}
        {%- endfor %}
      </div>
    </div>
    <div class="blk">
      <h2 class="sec"><span class="emo" aria-hidden="true">💼</span><span>Experience</span></h2>
      <div class="orgs">
        {%- for o in site.data.experience %}
        {% include timeline-row.html org=o.institution logo=o.logo role=o.role note=o.note dates=o.dates %}
        {%- endfor %}
      </div>
    </div>
  </div>
  <div class="col">
    <div class="blk">
      <h2 class="sec"><span class="emo" aria-hidden="true">🏆</span><span>Honors &amp; Awards</span></h2>
      <ul class="rows">
        {%- for a in site.data.awards %}
        <li class="row"><span class="emo row-emo" aria-hidden="true">{{ a.emoji }}</span><span class="row-text">{{ a.title }}{% if a.org %}, {{ a.org }}{% endif %}</span><em class="row-date">{{ a.year }}</em></li>
        {%- endfor %}
      </ul>
    </div>
    <div class="blk">
      <h2 class="sec"><span class="emo" aria-hidden="true">🤝</span><span>Service</span></h2>
      <ul class="rows">
        {%- for s in site.data.service %}
        <li class="row"><span class="row-dot" aria-hidden="true"></span><span class="row-text"><strong>{{ s.label }}:</strong> {{ s.text }}</span></li>
        {%- endfor %}
      </ul>
    </div>
    <div class="blk">
      <h2 class="sec"><span class="emo" aria-hidden="true">🧑‍🏫</span><span>Teaching</span></h2>
      <ul class="rows">
        {%- for t in site.data.teaching %}
        <li class="row"><span class="row-dot" aria-hidden="true"></span><span class="row-text">{{ t.html }}</span></li>
        {%- endfor %}
      </ul>
    </div>
  </div>
</section>

{%- assign months = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec" | split: "," -%}
{%- assign news_groups = site.data.news | group_by_exp: "n", "n.date | slice: 0, 4" -%}
{%- assign older_news = site.data.news | where: "older", true -%}
<section id="news" class="card" aria-labelledby="news-title">
  <div class="card-head">
    <h2 id="news-title"><span class="emo" aria-hidden="true">📰</span><span>News</span></h2>
  </div>
  <div class="news-body">
    {%- for g in news_groups %}
    {%- assign current = g.items | where_exp: "i", "i.older != true" %}
    <div class="yr-grp"{% if current.size == 0 %} data-older hidden{% endif %}>
      <span class="yr">{{ g.name }}</span>
      <ul class="n-list">
        {%- for n in g.items %}
        {% include news-row.html item=n months=months %}
        {%- endfor %}
      </ul>
    </div>
    {%- endfor %}
    {%- if older_news.size > 0 %}
    <div class="news-more">
      <button type="button" class="more-btn" data-show-older hidden>Show older</button>
    </div>
    {%- endif %}
  </div>
</section>

{%- assign pubs = site.data.publications -%}
{%- assign sc = p.scholar -%}
{%- capture asof %}Google Scholar, as of {{ sc.updated | date: "%-d %b %Y" }}{% endcapture -%}
<section id="publications" class="card" data-pubs aria-labelledby="pubs-title">
  <div class="card-head pub-head">
    <div class="ph-title">
      <h2 id="pubs-title"><span class="emo" aria-hidden="true">📝</span><span data-pub-title>Selected Publications</span></h2>
      <div class="shields">
        <a class="shield" href="{{ p.scholar_url }}" title="{{ asof }}" aria-label="Citations: {{ sc.citations }} ({{ asof }})"><span class="l"><span class="emo" aria-hidden="true">🎓</span>Citations</span><span class="r">{{ sc.citations }}</span></a>
        <a class="shield" href="{{ p.scholar_url }}" title="{{ asof }}" aria-label="h-index: {{ sc.h_index }} ({{ asof }})"><span class="l">h-index</span><span class="r">{{ sc.h_index }}</span></a>
      </div>
    </div>
    <span class="head-sep" aria-hidden="true"></span>
    <div class="seg" role="group" aria-label="Publication filter" data-pub-filter hidden>
      <button type="button" data-filter="selected" aria-pressed="true">Selected</button>
      <button type="button" data-filter="all" aria-pressed="false"><span>All</span><span class="count">{{ pubs.size }}</span></button>
    </div>
    <a class="head-link" href="{{ p.scholar_url }}"><span>Google Scholar</span>{% include icons/arrow.svg %}</a>
  </div>
  <div class="pub-list">
    {%- assign pub_years = pubs | group_by: "year" %}
    {%- for y in pub_years %}
    <h3 class="pub-year" hidden>{{ y.name }}</h3>
    {%- for pub in y.items %}
    {% include pub-row.html pub=pub %}
    {%- endfor %}
    {%- endfor %}
  </div>
  <div class="all-link"><a href="{{ p.scholar_url }}">All publications on Google Scholar »</a></div>
</section>
```

- [ ] **Step 4: Write `assets/css/site.css` (light theme; Task 5 adds the dark blocks)**

```css
/* Site styles for lizhyun.github.io.
   Every color is a custom property in the token blocks at the top; component
   rules only use var(). tools/contrast.mjs enforces this and checks contrast. */

/* ---------- tokens: light ---------- */
:root {
  color-scheme: light;
  /* surfaces */
  --ground: #f6f7f9;
  --card: #ffffff;
  --card-line: #e4e7ec;
  --hair: #dde2e8;
  --row-line: #eceef2;
  --box-bg: #f8f9fb;
  --box-line: #e8ebf0;
  --pub-hover: #f9fbfe;
  --sep: #dfe3e9;
  /* text */
  --ink: #161b26;
  --text: #2f3642;
  --text-2: #3d4450;
  --muted: #5a6270;
  --muted-2: #646c79;
  --nav-link: #505866;
  --icon: #505866;
  --year: #505866;
  --news-text: #2a303c;
  --rt: #6b7280;
  --dot: #8a919c;
  /* accent */
  --accent: #1b66c4;
  --accent-ink: #124f9c;
  --accent-wash: #eef4fc;
  --accent-line: #b9cff0;
  --on-accent: #ffffff;
  /* controls */
  --chip-bg: #ffffff;
  --chip-text: #2b3240;
  --btn-line: #d6dce4;
  --seg-bg: #f1f3f6;
  --seg-line: #e2e6eb;
  --seg-on-bg: #ffffff;
  --seg-off: #444c59;
  --count-bg: #e1e5ea;
  --type-bg: #ffffff;
  --type-line: #cfd5dd;
  --type-text: #505866;
  --oral-bg: #fef3c7;
  --oral-line: #f3cf7a;
  --oral-text: #92400e;
  --hot-bg: #c2410c;
  --on-hot: #ffffff;
  --hot-ring: #ffffff;
  --shield-l: #4b5563;
  --on-shield: #ffffff;
  /* always white: logos are black/navy on transparent and figures assume white */
  --frame: #ffffff;
  --frame-line: #e3e7ec;
  --frame-line-hover: #d3dae3;
  /* venue badges (same in both themes) */
  --on-badge: #ffffff;
  --v-neurips: #3b0f70;
  --v-icml: #1e3a8a;
  --v-aaai: #0d7c72;
  --v-arxiv: #b31b1b;
  --v-nn: #166534;
  --v-tnsm: #00629b;
  --v-tpami: #00629b;
  --v-eaai: #9a3412;
  --v-apin: #1f4e79;
  --v-aamas: #6b21a8;
  /* glass, background decoration, shadows */
  --nav-glass: rgba(255, 255, 255, 0.72);
  --nav-line: rgba(20, 30, 50, 0.08);
  --dots: rgba(30, 41, 59, 0.13);
  --mask-strong: rgba(0, 0, 0, 0.9);
  --mask-mid: rgba(0, 0, 0, 0.45);
  --mask-none: rgba(0, 0, 0, 0);
  --glow-blue: rgba(27, 102, 196, 0.22);
  --glow-blue-soft: rgba(27, 102, 196, 0.08);
  --glow-blue-none: rgba(27, 102, 196, 0);
  --glow-teal: rgba(20, 150, 140, 0.17);
  --glow-teal-soft: rgba(20, 150, 140, 0.05);
  --glow-teal-none: rgba(20, 150, 140, 0);
  --shade-1: rgba(16, 24, 40, 0.04);
  --shade-2: rgba(16, 24, 40, 0.09);
  --shade-3: rgba(16, 24, 40, 0.14);
  --shade-hot: rgba(194, 65, 12, 0.28);
  /* type */
  --sans: "Lato", "Helvetica Neue", Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Noto Color Emoji";
  --zh: "Noto Sans SC", "PingFang SC", "Noto Sans CJK SC", sans-serif;
  --mono: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, monospace;
  --emoji: "Apple Color Emoji", "Segoe UI Emoji", "Noto Color Emoji", sans-serif;
  --ease: cubic-bezier(.2, .7, .2, 1);
}

/* ---------- base ---------- */
*, *::before, *::after { box-sizing: border-box; }
[hidden] { display: none !important; }
html { background: var(--ground); }
body {
  margin: 0;
  font-family: var(--sans);
  background: var(--ground);
  color: var(--text);
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
}
a { color: var(--accent); text-decoration: none; }
a:hover { color: var(--accent-ink); text-decoration: underline; text-underline-offset: 3px; }
a:focus-visible, button:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; border-radius: 6px; }
button { font: inherit; cursor: pointer; }
p, h1, h2, h3, h4, ul { margin: 0; }
ul { padding: 0; list-style: none; }
#news, #publications { scroll-margin-top: 72px; }

.emo { font-family: var(--emoji); font-size: 1.05em; line-height: 1; font-style: normal; font-weight: 400; letter-spacing: 0; display: inline-block; flex: none; }
.emo-lead { margin-right: .4em; }

/* ---------- page shell and background ---------- */
.page { position: relative; width: 100%; min-height: 100vh; overflow-x: clip; background: var(--ground); }
.bg-dots {
  position: absolute; left: 0; top: 0; width: 100%; height: 760px; z-index: 0; pointer-events: none;
  background-image: radial-gradient(circle, var(--dots) 1px, transparent 1.3px);
  background-size: 22px 22px;
  background-position: 11px 11px;
  -webkit-mask-image: linear-gradient(to bottom, var(--mask-strong) 0%, var(--mask-mid) 45%, var(--mask-none) 100%);
  mask-image: linear-gradient(to bottom, var(--mask-strong) 0%, var(--mask-mid) 45%, var(--mask-none) 100%);
}
.glow { position: absolute; z-index: 0; pointer-events: none; border-radius: 50%; }
.glow-blue { left: -260px; top: -240px; width: 980px; height: 860px; background: radial-gradient(closest-side, var(--glow-blue), var(--glow-blue-soft) 55%, var(--glow-blue-none) 100%); }
.glow-teal { right: -300px; top: -160px; width: 860px; height: 780px; background: radial-gradient(closest-side, var(--glow-teal), var(--glow-teal-soft) 60%, var(--glow-teal-none) 100%); }

/* ---------- navbar ---------- */
.nav {
  position: sticky; top: 0; z-index: 10; height: 56px; display: flex; justify-content: center;
  background: var(--nav-glass);
  -webkit-backdrop-filter: saturate(180%) blur(14px);
  backdrop-filter: saturate(180%) blur(14px);
  border-bottom: 1px solid var(--nav-line);
  box-shadow: 0 1px 3px var(--shade-1);
}
.nav-in { width: min(1110px, 100% - 48px); height: 55px; display: flex; align-items: center; justify-content: space-between; gap: 16px; }
.brand { display: flex; align-items: baseline; gap: 8px; color: var(--ink); }
.brand:hover { color: var(--ink); text-decoration: none; }
.brand-en { font-weight: 700; font-size: 18px; line-height: 24px; }
.brand-zh { font-family: var(--zh); font-weight: 400; font-size: 15px; line-height: 24px; color: var(--muted); }
.nav-right { display: flex; align-items: center; gap: 8px; height: 55px; }
.nav-links { display: flex; align-items: stretch; gap: 8px; height: 55px; }
.nv { height: 55px; padding: 0 12px; display: flex; align-items: center; font-size: 15px; color: var(--nav-link); transition: color .15s ease; }
.nv:hover { color: var(--ink); text-decoration: none; }
.nv[aria-current="page"] { font-weight: 700; color: var(--ink); box-shadow: inset 0 -2px 0 var(--accent); }
.nav-sep { width: 1px; height: 20px; background: var(--sep); margin: 0 8px 0 4px; }
.theme-toggle {
  width: 40px; height: 40px; padding: 0; border-radius: 50%;
  border: 1px solid var(--hair); background: var(--chip-bg);
  display: flex; align-items: center; justify-content: center; line-height: 1;
  box-shadow: 0 1px 2px var(--shade-1);
  transition: border-color .15s ease, background-color .15s ease, transform .2s var(--ease);
}
.theme-toggle:hover { border-color: var(--accent-line); background: var(--accent-wash); transform: rotate(-12deg); }
.theme-toggle .emo { font-size: 17px; }

/* ---------- main column and cards ---------- */
main { position: relative; z-index: 1; display: flex; flex-direction: column; align-items: center; gap: 24px; padding: 32px 0 24px; }
.card {
  width: min(1110px, 100% - 48px);
  background: var(--card); border: 1px solid var(--card-line); border-radius: 12px;
  box-shadow: 0 1px 2px var(--shade-1), 0 4px 12px var(--shade-1);
  transition: transform .25s var(--ease), box-shadow .25s var(--ease);
}
.card:hover { transform: translateY(-2px); box-shadow: 0 2px 4px var(--shade-1), 0 14px 32px var(--shade-2); }

/* ---------- hero ---------- */
.hero { padding: 40px 48px; display: flex; flex-direction: column; gap: 32px; }
.hero-top { display: flex; align-items: flex-start; gap: 48px; }
.hero-text { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 24px; }
.hero-head { display: flex; flex-direction: column; gap: 8px; }
.hero h1 { display: flex; align-items: baseline; gap: 16px; font-weight: 300; font-size: 42px; line-height: 48px; letter-spacing: -.005em; color: var(--ink); }
.zh-name { font-family: var(--zh); font-weight: 300; font-size: 28px; line-height: 48px; letter-spacing: .06em; color: var(--muted); }
.zh-name ruby { ruby-position: over; }
.zh-name rt { font-family: var(--sans); font-weight: 400; font-size: 11.5px; line-height: 1; letter-spacing: .02em; color: var(--rt); padding-bottom: 2px; }
.hero-sub { display: flex; align-items: baseline; flex-wrap: wrap; gap: 8px 24px; font-size: 15.5px; line-height: 24px; color: var(--text-2); }
.hero-sub .loc { color: var(--nav-link); }
.bio { display: flex; flex-direction: column; gap: 16px; font-size: 16px; line-height: 26px; color: var(--text); }
.avatar { flex: none; width: 160px; height: 160px; padding: 4px; border-radius: 50%; border: 1px solid var(--hair); background: var(--frame); box-shadow: 0 2px 10px var(--shade-1); }
.avatar img { display: block; width: 150px; height: 150px; border-radius: 50%; object-fit: cover; }

.hero-boxes { display: flex; flex-direction: column; gap: 16px; }
.box { display: flex; flex-direction: column; gap: 12px; padding: 16px 20px; background: var(--box-bg); border: 1px solid var(--box-line); border-radius: 10px; }
.box-title { display: flex; align-items: baseline; gap: 8px; font-size: 14px; line-height: 20px; font-weight: 700; color: var(--ink); }
.chips { display: flex; flex-wrap: wrap; gap: 8px; }
.chip { display: inline-flex; align-items: center; gap: 7px; min-height: 32px; padding: 0 13px; border: 1px solid var(--hair); border-radius: 999px; background: var(--chip-bg); color: var(--chip-text); font-size: 13.5px; line-height: 20px; white-space: nowrap; }
.chip .ico { flex: none; }
.chip-plain .ico { color: var(--icon); }
a.chip { transition: border-color .15s ease, color .15s ease; }
a.chip:hover { border-color: var(--accent); color: var(--accent); text-decoration: none; }
.chip .mono { font-family: var(--mono); font-size: 12.5px; }
.chip .zh { font-family: var(--zh); font-size: 13px; font-weight: 400; }
.chip .emo { font-size: 14px; }
.chip strong { font-weight: 700; color: var(--ink); }
.chip .dot-sep { color: var(--rt); margin: 0 1px; }

/* ---------- two-column card ---------- */
.cols { padding: 36px 40px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 48px; align-items: start; }
.col { display: flex; flex-direction: column; gap: 32px; }
.blk { display: flex; flex-direction: column; gap: 16px; }
.sec { display: flex; align-items: baseline; gap: 8px; font-size: 17px; line-height: 24px; font-weight: 700; color: var(--ink); }
.orgs { display: flex; flex-direction: column; gap: 16px; }
.org { display: grid; grid-template-columns: 40px minmax(0, 1fr); gap: 12px; align-items: center; }
.logo { width: 40px; height: 40px; padding: 4px; border-radius: 9px; border: 1px solid var(--frame-line); background: var(--frame); box-shadow: 0 1px 2px var(--shade-1); display: flex; align-items: center; justify-content: center; }
.logo img { display: block; width: 30px; height: 30px; object-fit: contain; }
.org-body { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
.org-name { font-size: 15px; line-height: 22px; color: var(--ink); }
.org-meta { display: flex; justify-content: space-between; align-items: baseline; gap: 16px; font-size: 13px; line-height: 20px; color: var(--muted); }
.org-meta em { flex: none; font-style: italic; color: var(--muted-2); }
.rows { display: flex; flex-direction: column; gap: 8px; }
.row { display: flex; align-items: baseline; gap: 10px; font-size: 14px; line-height: 22px; color: var(--text); }
.row-emo { width: 20px; text-align: center; }
.row-dot { flex: none; width: 20px; height: 22px; display: flex; align-items: center; justify-content: center; align-self: flex-start; }
.row-dot::before { content: ""; width: 5px; height: 5px; border-radius: 50%; background: var(--dot); }
.row-text { flex: 1; min-width: 0; }
.row-text strong { font-weight: 700; color: var(--ink); }
.row-date { flex: none; font-style: italic; font-size: 13px; color: var(--muted-2); }

/* ---------- card header (news, publications) ---------- */
.card-head { display: flex; align-items: center; gap: 16px; padding: 16px 40px; border-bottom: 1px solid var(--row-line); min-height: 57px; }
.card-head h2 { display: flex; align-items: baseline; gap: 8px; font-size: 18px; line-height: 24px; font-weight: 700; color: var(--ink); }

/* ---------- news ---------- */
.news-body { display: flex; flex-direction: column; padding: 12px 40px 16px; }
.yr-grp { display: grid; grid-template-columns: 72px minmax(0, 1fr); gap: 0 16px; align-items: start; }
.yr-grp + .yr-grp { border-top: 1px solid var(--row-line); }
.yr { padding-top: 8px; font-size: 14px; line-height: 22px; font-weight: 700; color: var(--year); }
.n-item { display: flex; align-items: baseline; gap: 12px; padding: 8px 0; }
.n-emo { width: 22px; text-align: center; }
.n-text { flex: 1; min-width: 0; font-size: 15px; line-height: 22px; color: var(--news-text); }
.n-date { flex: none; width: 88px; text-align: right; font-style: italic; font-size: 13.5px; line-height: 22px; color: var(--muted-2); }
.new-pill { display: inline-block; vertical-align: 1px; margin-left: 8px; height: 18px; padding: 0 7px; border-radius: 999px; background: var(--accent); color: var(--on-accent); font-size: 10.5px; line-height: 18px; font-weight: 700; letter-spacing: .08em; }
.news-more { display: flex; justify-content: center; padding-top: 8px; }
.more-btn { height: 32px; padding: 0 16px; border: 1px solid var(--btn-line); border-radius: 999px; background: var(--chip-bg); color: var(--accent); font-size: 13px; font-weight: 700; }
.more-btn:hover { background: var(--accent-wash); border-color: var(--accent-line); }

/* ---------- publications ---------- */
.ph-title { display: flex; align-items: center; gap: 16px; }
.shields { display: flex; align-items: center; gap: 8px; }
.shield { display: inline-flex; height: 20px; border-radius: 4px; overflow: hidden; font-size: 11.5px; line-height: 20px; font-weight: 700; color: var(--on-shield); box-shadow: 0 1px 1px var(--shade-2); transition: box-shadow .15s ease; }
.shield:hover { color: var(--on-shield); text-decoration: none; box-shadow: 0 2px 6px var(--shade-3); }
.shield .l { display: inline-flex; align-items: center; gap: 5px; padding: 0 7px; background: var(--shield-l); }
.shield .r { padding: 0 7px; background: var(--accent); color: var(--on-accent); }
.shield .emo { font-size: 12px; }
.head-sep { width: 1px; height: 20px; background: var(--sep); }
.seg { display: flex; align-items: center; gap: 2px; padding: 3px; background: var(--seg-bg); border: 1px solid var(--seg-line); border-radius: 8px; }
.seg button { height: 28px; padding: 0 12px; border: 0; border-radius: 6px; background: transparent; color: var(--seg-off); font-size: 13px; font-weight: 700; display: flex; align-items: center; gap: 6px; }
.seg button[aria-pressed="true"] { background: var(--seg-on-bg); color: var(--accent); box-shadow: 0 1px 2px var(--shade-3); }
.seg .count { height: 18px; padding: 0 6px; border-radius: 999px; background: var(--count-bg); color: var(--text-2); font-size: 11.5px; line-height: 18px; font-weight: 700; }
.head-link { margin-left: auto; display: flex; align-items: center; gap: 6px; font-size: 14px; line-height: 22px; font-weight: 700; }

.pub-year { padding: 20px 40px 6px; font-size: 14px; line-height: 20px; font-weight: 700; letter-spacing: .04em; color: var(--year); border-bottom: 1px solid var(--row-line); }
.pub { display: grid; grid-template-columns: 200px minmax(0, 1fr); gap: 28px; padding: 24px 40px; border-bottom: 1px solid var(--row-line); transition: background-color .2s ease; }
.pub-compact { grid-template-columns: minmax(0, 1fr); }
.pub:hover { background: var(--pub-hover); }
.thumb-wrap { position: relative; width: 200px; height: 134px; }
.thumb { display: block; width: 200px; height: 134px; padding: 6px; background: var(--frame); border: 1px solid var(--frame-line); border-radius: 6px; overflow: hidden; transition: border-color .2s ease, box-shadow .2s ease; }
.pub:hover .thumb { border-color: var(--frame-line-hover); box-shadow: 0 2px 8px var(--shade-1); }
.thumb img { display: block; width: 100%; height: 100%; object-fit: contain; transition: transform .35s var(--ease); }
.pub:hover .thumb img { transform: scale(1.03); }
.hot { position: absolute; top: -8px; left: -8px; z-index: 1; display: inline-flex; align-items: center; gap: 4px; height: 22px; padding: 0 9px 0 7px; border-radius: 999px; background: var(--hot-bg); color: var(--on-hot); font-size: 11.5px; line-height: 22px; font-weight: 700; letter-spacing: .02em; box-shadow: 0 2px 6px var(--shade-hot), 0 0 0 2px var(--hot-ring); }
.hot .emo { font-size: 12px; }
.pub-body { display: flex; flex-direction: column; gap: 8px; min-width: 0; }
.pub-title { font-size: 19px; line-height: 26px; font-weight: 400; color: var(--ink); }
.tl { color: var(--ink); transition: color .15s ease; }
.tl:hover { color: var(--accent); text-decoration: none; }
.authors { font-size: 13.5px; line-height: 20px; color: var(--text-2); }
.authors strong { font-weight: 700; color: var(--ink); }
.meta { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; min-height: 20px; }
.venue { height: 20px; padding: 0 8px; border-radius: 5px; color: var(--on-badge); font-size: 12px; line-height: 20px; font-weight: 700; letter-spacing: .01em; }
.v-neurips { background: var(--v-neurips); }
.v-icml { background: var(--v-icml); }
.v-aaai { background: var(--v-aaai); }
.v-arxiv { background: var(--v-arxiv); }
.v-nn { background: var(--v-nn); }
.v-tnsm { background: var(--v-tnsm); }
.v-tpami { background: var(--v-tpami); }
.v-eaai { background: var(--v-eaai); }
.v-apin { background: var(--v-apin); }
.v-aamas { background: var(--v-aamas); }
.type { height: 18px; padding: 0 7px; border-radius: 999px; border: 1px solid var(--type-line); background: var(--type-bg); color: var(--type-text); font-size: 11px; line-height: 16px; font-weight: 700; letter-spacing: .02em; }
.oral { display: inline-flex; align-items: center; gap: 4px; height: 20px; padding: 0 8px; border-radius: 999px; border: 1px solid var(--oral-line); background: var(--oral-bg); color: var(--oral-text); font-size: 11.5px; line-height: 18px; font-weight: 700; letter-spacing: .02em; }
.oral .emo { font-size: 12px; }
.tldr { font-size: 13.5px; line-height: 20px; color: var(--muted); }
.links { display: flex; flex-wrap: wrap; gap: 8px; padding-top: 2px; }
.btn { display: inline-flex; align-items: center; gap: 6px; height: 28px; padding: 0 12px 0 10px; border: 1px solid var(--btn-line); border-radius: 999px; background: var(--chip-bg); color: var(--accent); font-size: 13px; line-height: 20px; font-weight: 700; transition: background-color .15s ease, border-color .15s ease, color .15s ease; }
.btn:hover { background: var(--accent-wash); border-color: var(--accent-line); color: var(--accent-ink); text-decoration: none; }
.btn .emo { font-size: 13.5px; }
.all-link { display: flex; justify-content: flex-end; padding: 16px 40px; }
.all-link a { font-size: 14px; line-height: 22px; font-weight: 700; }

/* ---------- footer and 404 ---------- */
.footer { position: relative; z-index: 1; width: min(1110px, 100% - 48px); margin: 0 auto; padding: 0 0 32px; display: flex; flex-wrap: wrap; justify-content: space-between; gap: 8px 16px; font-size: 13.5px; line-height: 22px; color: var(--muted); }
.notfound { padding: 48px; display: flex; flex-direction: column; align-items: flex-start; gap: 16px; }
.notfound h1 { font-weight: 300; font-size: 36px; line-height: 44px; color: var(--ink); }

/* ---------- responsive ---------- */
@media (max-width: 1023px) {
  .hero { padding: 28px 24px; }
  .hero-top { flex-direction: column-reverse; gap: 20px; }
  .cols { grid-template-columns: minmax(0, 1fr); gap: 32px; padding: 28px 24px; }
  .card-head, .news-body, .pub, .pub-year, .all-link { padding-left: 24px; padding-right: 24px; }
  .pub-head { flex-wrap: wrap; }
  .ph-title { flex-basis: 100%; }
  .head-sep { display: none; }
}
@media (max-width: 639px) {
  .nav-in, .card, .footer { width: calc(100% - 24px); }
  .nv-home { display: none; }
  .hero h1 { flex-wrap: wrap; row-gap: 4px; font-size: 34px; line-height: 40px; }
  .ph-title { flex-direction: column; align-items: flex-start; gap: 8px; }
  .pub { grid-template-columns: minmax(0, 1fr); gap: 16px; }
  .thumb-wrap, .thumb { width: 100%; height: auto; aspect-ratio: 3 / 2; }
  .yr-grp { grid-template-columns: minmax(0, 1fr); }
  .yr { padding-top: 12px; font-size: 13px; }
  .n-item { flex-wrap: wrap; row-gap: 0; }
  .n-date { width: auto; flex-basis: 100%; text-align: left; padding-left: 34px; }
  .org-meta { flex-direction: column; gap: 0; }
  .chip { white-space: normal; padding-top: 5px; padding-bottom: 5px; }
}

/* ---------- motion ---------- */
@media (prefers-reduced-motion: reduce) {
  .card, .pub, .thumb, .thumb img, .btn, .chip, .shield, .theme-toggle, .tl, .nv { transition: none !important; }
  .card:hover { transform: none; }
  .pub:hover .thumb img { transform: none; }
  .theme-toggle:hover { transform: none; }
}
```

- [ ] **Step 5: Run the static gate to verify it passes**

Run: `tools/build.sh && node tools/browser.mjs static`
Expected: `BUILD OK`, then all `PASS` lines (4 viewport/scheme combinations × 11 checks) and `BROWSER OK`.

- [ ] **Step 6: Visual check against the mockup**

Run: `node tools/browser.mjs screens`
Open `tools/out/home-1440-light.png` and compare it with `docs/superpowers/specs/2026-09-30-homepage-redesign/mockup/D-rich.jpg` using the Read tool on both.

Expected differences:
- the Selected/All toggle and the 🌙 button are absent (they appear with JS in Task 5);
- the fonts and emoji are the same;
- there are no † marks;
- the COMPASS news text differs.

Fix any layout mismatch, such as spacing, alignment or wrapping, then re-run Step 5.

- [ ] **Step 7: Commit**

```bash
git add _layouts _includes assets/css tools/package.json tools/package-lock.json tools/browser.mjs index.html
git commit -m "feat: render the home page from data with the D+ layout (light theme)

Co-Authored-By: <attribution line 1>
Claude-Session: <attribution line 2>"
```

---

### Task 5: Interactions and dark theme

**Files:**
- Create: `assets/js/site.js`
- Modify: `_layouts/default.html` (add one `<script>` line before `</body>`), `assets/css/site.css` (append the dark token blocks after the light block)

**Interfaces:**
- Consumes: the Task 4 DOM contract.
- Produces: `localStorage.theme` ∈ {`"light"`, `"dark"`}, and `html[data-theme]`.

- [ ] **Step 1: Run the behavior gate to verify it fails**

Run: `tools/build.sh >/dev/null && node tools/browser.mjs behavior`
Expected: `FAIL [JS 1440] filter shown with JS` and further failures. Exit 1.

- [ ] **Step 2: Write `assets/js/site.js`**

```js
// Progressive enhancement for the home page: publication filter, older news,
// theme toggle. Every control is rendered hidden and only shown here, so the
// page is complete without JavaScript.
(function () {
  'use strict';
  var root = document.documentElement;

  // ---- theme ----
  var themeBtn = document.querySelector('[data-theme-toggle]');
  var darkQuery = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;

  function effectiveTheme() {
    var t = root.getAttribute('data-theme');
    if (t === 'light' || t === 'dark') return t;
    return darkQuery && darkQuery.matches ? 'dark' : 'light';
  }

  function renderThemeButton() {
    var dark = effectiveTheme() === 'dark';
    var label = dark ? 'Switch to light theme' : 'Switch to dark theme';
    themeBtn.querySelector('.emo').textContent = dark ? '☀️' : '🌙';
    themeBtn.setAttribute('aria-label', label);
    themeBtn.title = label;
  }

  if (themeBtn) {
    themeBtn.hidden = false;
    renderThemeButton();
    themeBtn.addEventListener('click', function () {
      var next = effectiveTheme() === 'dark' ? 'light' : 'dark';
      root.setAttribute('data-theme', next);
      try { localStorage.setItem('theme', next); } catch (e) { /* storage blocked: theme lasts this visit only */ }
      renderThemeButton();
    });
    if (darkQuery && darkQuery.addEventListener) darkQuery.addEventListener('change', renderThemeButton);
  }

  // ---- publications: Selected / All ----
  var pubs = document.querySelector('[data-pubs]');
  var filter = pubs && pubs.querySelector('[data-pub-filter]');
  if (filter) {
    var title = pubs.querySelector('[data-pub-title]');
    var rows = pubs.querySelectorAll('article.pub');
    var years = pubs.querySelectorAll('.pub-year');
    var show = function (mode) {
      var all = mode === 'all';
      rows.forEach(function (row) { row.hidden = !all && row.getAttribute('data-selected') !== 'true'; });
      years.forEach(function (year) { year.hidden = !all; });
      filter.querySelectorAll('button[data-filter]').forEach(function (b) {
        b.setAttribute('aria-pressed', String(b.getAttribute('data-filter') === mode));
      });
      title.textContent = all ? 'Publications' : 'Selected Publications';
    };
    filter.hidden = false;
    filter.addEventListener('click', function (event) {
      var button = event.target.closest('button[data-filter]');
      if (button) show(button.getAttribute('data-filter'));
    });
  }

  // ---- news: Show older ----
  var more = document.querySelector('[data-show-older]');
  if (more) {
    more.hidden = false;
    more.addEventListener('click', function () {
      document.querySelectorAll('[data-older]').forEach(function (el) { el.hidden = false; });
      var wrap = more.parentNode;
      wrap.parentNode.removeChild(wrap);
    });
  }
})();
```

- [ ] **Step 3: Load the script from the layout**

In `_layouts/default.html`, replace:

```html
</div>
</body>
```

with:

```html
</div>
<script src="{{ '/assets/js/site.js' | relative_url }}" defer></script>
</body>
```

- [ ] **Step 4: Append the dark token blocks to `assets/css/site.css`**

Insert this directly after the closing `}` of the light `:root` block, before `/* ---------- base ---------- */`. The two blocks must stay identical; `tools/contrast.mjs` checks this.

```css
/* ---------- tokens: dark (OS setting without an explicit choice) ---------- */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    color-scheme: dark;
    --ground: #0f1318;
    --card: #161b22;
    --card-line: #262d38;
    --hair: #2c3440;
    --row-line: #222934;
    --box-bg: #1b212a;
    --box-line: #29313c;
    --pub-hover: #1a2029;
    --sep: #2c3440;
    --ink: #eef1f5;
    --text: #d5dae2;
    --text-2: #c6ccd6;
    --muted: #a3abb8;
    --muted-2: #9aa3b0;
    --nav-link: #b7bfcb;
    --icon: #aab2be;
    --year: #b7bfcb;
    --news-text: #d5dae2;
    --rt: #9aa3b0;
    --dot: #6b7482;
    --accent: #6aa9ff;
    --accent-ink: #9cc6ff;
    --accent-wash: #1a2636;
    --accent-line: #2f4a70;
    --on-accent: #0b1220;
    --chip-bg: #1b212a;
    --chip-text: #d5dae2;
    --btn-line: #2f3845;
    --seg-bg: #1b212a;
    --seg-line: #2c3440;
    --seg-on-bg: #262e3a;
    --seg-off: #b7bfcb;
    --count-bg: #2c3440;
    --type-bg: #161b22;
    --type-line: #3a4350;
    --type-text: #b7bfcb;
    --oral-bg: #3a2a0a;
    --oral-line: #6b4c12;
    --oral-text: #fcd34d;
    --hot-ring: #161b22;
    --shield-l: #374151;
    --frame-line: #2c3440;
    --frame-line-hover: #3a4350;
    --nav-glass: rgba(22, 27, 34, 0.72);
    --nav-line: rgba(255, 255, 255, 0.08);
    --dots: rgba(200, 210, 225, 0.08);
    --glow-blue: rgba(106, 169, 255, 0.16);
    --glow-blue-soft: rgba(106, 169, 255, 0.05);
    --glow-blue-none: rgba(106, 169, 255, 0);
    --glow-teal: rgba(45, 190, 175, 0.12);
    --glow-teal-soft: rgba(45, 190, 175, 0.04);
    --glow-teal-none: rgba(45, 190, 175, 0);
    --shade-1: rgba(0, 0, 0, 0.25);
    --shade-2: rgba(0, 0, 0, 0.35);
    --shade-3: rgba(0, 0, 0, 0.45);
  }
}

/* ---------- tokens: dark (explicit choice via the theme button) ---------- */
:root[data-theme="dark"] {
  color-scheme: dark;
  --ground: #0f1318;
  --card: #161b22;
  --card-line: #262d38;
  --hair: #2c3440;
  --row-line: #222934;
  --box-bg: #1b212a;
  --box-line: #29313c;
  --pub-hover: #1a2029;
  --sep: #2c3440;
  --ink: #eef1f5;
  --text: #d5dae2;
  --text-2: #c6ccd6;
  --muted: #a3abb8;
  --muted-2: #9aa3b0;
  --nav-link: #b7bfcb;
  --icon: #aab2be;
  --year: #b7bfcb;
  --news-text: #d5dae2;
  --rt: #9aa3b0;
  --dot: #6b7482;
  --accent: #6aa9ff;
  --accent-ink: #9cc6ff;
  --accent-wash: #1a2636;
  --accent-line: #2f4a70;
  --on-accent: #0b1220;
  --chip-bg: #1b212a;
  --chip-text: #d5dae2;
  --btn-line: #2f3845;
  --seg-bg: #1b212a;
  --seg-line: #2c3440;
  --seg-on-bg: #262e3a;
  --seg-off: #b7bfcb;
  --count-bg: #2c3440;
  --type-bg: #161b22;
  --type-line: #3a4350;
  --type-text: #b7bfcb;
  --oral-bg: #3a2a0a;
  --oral-line: #6b4c12;
  --oral-text: #fcd34d;
  --hot-ring: #161b22;
  --shield-l: #374151;
  --frame-line: #2c3440;
  --frame-line-hover: #3a4350;
  --nav-glass: rgba(22, 27, 34, 0.72);
  --nav-line: rgba(255, 255, 255, 0.08);
  --dots: rgba(200, 210, 225, 0.08);
  --glow-blue: rgba(106, 169, 255, 0.16);
  --glow-blue-soft: rgba(106, 169, 255, 0.05);
  --glow-blue-none: rgba(106, 169, 255, 0);
  --glow-teal: rgba(45, 190, 175, 0.12);
  --glow-teal-soft: rgba(45, 190, 175, 0.04);
  --glow-teal-none: rgba(45, 190, 175, 0);
  --shade-1: rgba(0, 0, 0, 0.25);
  --shade-2: rgba(0, 0, 0, 0.35);
  --shade-3: rgba(0, 0, 0, 0.45);
}
```

- [ ] **Step 5: Run both browser gates to verify they pass**

Run: `tools/build.sh >/dev/null && node tools/browser.mjs static && node tools/browser.mjs behavior`
Expected: all `PASS`, `BROWSER OK` twice.

- [ ] **Step 6: Commit**

```bash
git add assets/js/site.js _layouts/default.html assets/css/site.css
git commit -m "feat: add publication filter, older news, and persistent dark theme

Co-Authored-By: <attribution line 1>
Claude-Session: <attribution line 2>"
```

---

### Task 6: Contrast and token gate

**Files:**
- Create: `tools/contrast.mjs`

**Interfaces:**
- Consumes: the three token blocks in `site.css` (Tasks 4–5).
- Produces: `node tools/contrast.mjs` prints `CONTRAST OK` and exits 0, or prints `FAIL` lines and exits 1.

- [ ] **Step 1: Write `tools/contrast.mjs`**

```js
// Gate 6: every color in site.css is a token, the two dark blocks are identical,
// every used var() is defined, and every text/background pair used by the CSS
// passes WCAG AA (4.5:1) in both themes. Usage: node tools/contrast.mjs
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const css = fs.readFileSync(path.join(ROOT, 'assets/css/site.css'), 'utf8').replace(/\/\*[\s\S]*?\*\//g, '');
let failures = 0;
const fail = (msg) => { console.log(`FAIL ${msg}`); failures += 1; };

function block(re) {
  const m = re.exec(css);
  if (!m) return null;
  let depth = 1;
  let i = m.index + m[0].length;
  const start = i;
  while (depth > 0 && i < css.length) {
    if (css[i] === '{') depth += 1;
    else if (css[i] === '}') depth -= 1;
    i += 1;
  }
  return { start: m.index, end: i, body: css.slice(start, i - 1) };
}
const tokens = (body) => Object.fromEntries([...body.matchAll(/(--[\w-]+)\s*:\s*([^;]+);/g)].map((m) => [m[1], m[2].trim()]));

const light = block(/(?:^|\n):root\s*\{/);
const darkMedia = block(/:root:not\(\[data-theme="light"\]\)\s*\{/);
const darkAttr = block(/:root\[data-theme="dark"\]\s*\{/);
if (!light || !darkMedia || !darkAttr) {
  console.log('FAIL missing a token block (light :root, media dark, [data-theme="dark"])');
  process.exit(1);
}
const L = tokens(light.body);
const Dm = tokens(darkMedia.body);
const Da = tokens(darkAttr.body);
if (JSON.stringify(Dm) !== JSON.stringify(Da)) fail('the two dark token blocks differ');
for (const k of Object.keys(Da)) if (!(k in L)) fail(`dark token ${k} is not defined in the light block`);
const D = { ...L, ...Da };

// 1. no literal colors outside the token blocks
let rest = css;
for (const b of [darkAttr, darkMedia, light].sort((a, c) => c.start - a.start)) rest = rest.slice(0, b.start) + rest.slice(b.end);
for (const m of rest.matchAll(/[\w-]+\s*:\s*([^;{}]+)/g)) {
  const lit = m[1].match(/#[0-9a-fA-F]{3,8}\b|\brgba?\(|\bhsla?\(/);
  if (lit) fail(`literal color outside the token blocks: "${m[0].trim().slice(0, 80)}"`);
}
// 2. every var() used is defined
for (const u of new Set([...css.matchAll(/var\((--[\w-]+)/g)].map((m) => m[1]))) if (!(u in L)) fail(`var(${u}) is used but not defined`);

// 3. contrast
function parse(value) {
  const v = value.trim();
  let m = v.match(/^#([0-9a-f]{6})$/i);
  if (m) return [0, 2, 4].map((i) => parseInt(m[1].slice(i, i + 2), 16)).concat(1);
  m = v.match(/^#([0-9a-f]{3})$/i);
  if (m) return [...m[1]].map((h) => parseInt(h + h, 16)).concat(1);
  m = v.match(/^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)$/);
  if (m) return [+m[1], +m[2], +m[3], m[4] === undefined ? 1 : +m[4]];
  throw new Error(`cannot parse color "${value}"`);
}
const over = (fg, bg) => [0, 1, 2].map((i) => Math.round(fg[3] * fg[i] + (1 - fg[3]) * bg[i])).concat(1);
const lum = ([r, g, b]) => {
  const f = (c) => { const s = c / 255; return s <= 0.03928 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4; };
  return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
};
const ratio = (a, b) => { const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x); return (hi + 0.05) / (lo + 0.05); };

// Every (text, background) pair the stylesheet actually uses.
const PAIRS = [
  ['--ink', '--card'], ['--text', '--card'], ['--text-2', '--card'], ['--muted', '--card'], ['--muted-2', '--card'],
  ['--accent', '--card'], ['--accent-ink', '--card'], ['--year', '--card'], ['--news-text', '--card'], ['--rt', '--card'],
  ['--muted', '--ground'], ['--ink', '--ground'],
  ['--ink', '--nav-glass'], ['--nav-link', '--nav-glass'], ['--muted', '--nav-glass'],
  ['--ink', '--box-bg'], ['--chip-text', '--chip-bg'], ['--accent', '--chip-bg'], ['--ink', '--chip-bg'], ['--rt', '--chip-bg'],
  ['--seg-off', '--seg-bg'], ['--accent', '--seg-on-bg'], ['--text-2', '--count-bg'],
  ['--type-text', '--type-bg'], ['--oral-text', '--oral-bg'], ['--on-hot', '--hot-bg'],
  ['--on-accent', '--accent'], ['--on-shield', '--shield-l'],
  ['--accent', '--accent-wash'], ['--accent-ink', '--accent-wash'],
  ['--ink', '--pub-hover'], ['--text-2', '--pub-hover'], ['--muted', '--pub-hover'], ['--muted-2', '--pub-hover'], ['--accent', '--pub-hover'],
  ...['neurips', 'icml', 'aaai', 'arxiv', 'nn', 'tnsm', 'tpami', 'eaai', 'apin', 'aamas'].map((v) => ['--on-badge', `--v-${v}`]),
];
for (const [name, T] of [['light', L], ['dark', D]]) {
  const ground = parse(T['--ground']);
  for (const [fgName, bgName] of PAIRS) {
    let bg = parse(T[bgName]);
    if (bg[3] < 1) bg = over(bg, ground);
    const r = ratio(parse(T[fgName]), bg);
    const line = `${name.padEnd(5)} ${fgName} on ${bgName}: ${r.toFixed(2)}`;
    if (r < 4.5) fail(line); else console.log(`PASS ${line}`);
  }
}
if (failures) { console.log(`${failures} problem(s)`); process.exit(1); }
console.log('CONTRAST OK');
```

- [ ] **Step 2: Prove the gate catches a violation**

```bash
cp assets/css/site.css tools/out/site.css.bak
printf '\n.probe { color: #123456; }\n' >> assets/css/site.css
node tools/contrast.mjs; echo "exit=$?"
cp tools/out/site.css.bak assets/css/site.css
```

Expected: `FAIL literal color outside the token blocks: ".probe { color: #123456"` (or similar) and `exit=1`. The file is then restored.

- [ ] **Step 3: Run the gate on the real stylesheet**

Run: `node tools/contrast.mjs`
Expected: 90 `PASS` lines (45 pairs × 2 themes) and `CONTRAST OK`.

If a pair fails, adjust that token's value in the matching theme block. For dark, edit both blocks identically. Re-run until it passes, then re-run `node tools/browser.mjs behavior`: the dark ground must stay `#0f1318`.

- [ ] **Step 4: Commit**

```bash
git add tools/contrast.mjs assets/css/site.css
git commit -m "test: add color-token and WCAG contrast gate

Co-Authored-By: <attribution line 1>
Claude-Session: <attribution line 2>"
```

---

### Task 7: SEO output, redirects for old URLs, and the 404 page

**Files:**
- Create:
  - `_layouts/redirect.html`
  - `publications/index.html`, `projects/index.html`, `projects/compass/index.html`, `blog/index.html`
  - `404.html`
  - `tools/check-output.rb`

**Interfaces:**
- Consumes: `index.html` front matter (Task 1) and `default.html` (Task 4).
- Produces: `ruby tools/check-output.rb` prints `OUTPUT OK` and exits 0, or exits 1.

- [ ] **Step 1: Write the failing gate `tools/check-output.rb`**

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# Checks the built site's SEO tags, sitemap, robots.txt, redirects and 404 page (spec §7, §8).
# Uses the system Nokogiri; run with plain `ruby` (not `bundle exec`).
require "nokogiri"

SITE = File.expand_path("../_site", __dir__)
abort "Build the site first: tools/build.sh" unless File.exist?(File.join(SITE, "index.html"))
$failures = 0

def check(ok, msg)
  puts "#{ok ? 'PASS' : 'FAIL'} #{msg}"
  $failures += 1 unless ok
end

def page(rel)
  Nokogiri::HTML(File.read(File.join(SITE, rel)))
end

home = page("index.html")
check(home.at("title")&.text == "Zhiyuan Li (李志圆)", "home <title> is exactly 'Zhiyuan Li (李志圆)'")
ld = home.css('script[type="application/ld+json"]').map(&:text).join
check(ld.include?('"@type":"Person"'), "JSON-LD @type is Person")
check(ld.include?("https://orcid.org/0000-0002-1804-3485"), "JSON-LD sameAs lists ORCID")
check(home.at('meta[property="og:image"]')&.[]("content") == "https://lizhyun.github.io/assets/img/avatar.png", "og:image is the avatar")
check(home.at('meta[name="description"]')&.[]("content").to_s.start_with?("Postdoctoral researcher at Aalto University"), "meta description is set")
check(home.css('link[rel="canonical"]').size == 1, "home has exactly one canonical link")
check(!File.read(File.join(SITE, "index.html")).include?("†"), "no corresponding-author marks")

sitemap = File.read(File.join(SITE, "sitemap.xml"))
check(sitemap.include?("<loc>https://lizhyun.github.io/</loc>"), "sitemap lists the home page")
check(sitemap.include?("Li_Zhiyuan_CV.pdf"), "sitemap lists the English CV")
%w[Li_Zhiyuan_CV_zh.pdf /publications/ /projects/ /blog/ 404.html].each { |s| check(!sitemap.include?(s), "sitemap omits #{s}") }
robots_path = File.join(SITE, "robots.txt")
check(File.exist?(robots_path) && File.read(robots_path).include?("Sitemap: https://lizhyun.github.io/sitemap.xml"), "robots.txt points to the sitemap")

{
  "publications/index.html" => "/#publications", "projects/index.html" => "/#publications",
  "projects/compass/index.html" => "/#publications", "blog/index.html" => "/"
}.each do |rel, dest|
  unless File.exist?(File.join(SITE, rel))
    check(false, "#{rel} exists")
    next
  end
  d = page(rel)
  check(d.at('meta[http-equiv="refresh"]')&.[]("content") == "0; url=#{dest}", "#{rel} refreshes to #{dest}")
  check(d.at('meta[name="robots"]')&.[]("content") == "noindex", "#{rel} is noindex")
  check(d.css('link[rel="canonical"]').size == 1, "#{rel} has exactly one canonical link")
  check(!d.at("a[href=\"#{dest}\"]").nil?, "#{rel} has a visible fallback link")
  check(!d.at('link[rel~="icon"]').nil?, "#{rel} links the favicon")
end

if File.exist?(File.join(SITE, "404.html"))
  d = page("404.html")
  check(d.at("title")&.text.to_s.start_with?("Page not found"), "404 title starts with 'Page not found'")
  check(d.css('link[rel="stylesheet"]').any? { |l| l["href"].start_with?("/assets/") }, "404 loads CSS by a root-relative URL")
  check(!d.at('a[href="/"]').nil?, "404 links home")
else
  check(false, "404.html exists")
end

texts = Dir.glob(File.join(SITE, "**", "*")).select { |f| File.file?(f) && f.end_with?(".html", ".css", ".js", ".xml") }
check(texts.none? { |f| File.read(f).include?("polyfill.io") }, "no polyfill.io references")
check(!File.read(File.join(SITE, "assets/css/site.css")).match?(/\b1440px\b/), "no fixed 1440px widths in CSS")
check(!File.exist?(File.join(SITE, "feed.xml")), "no feed.xml")

if $failures.zero?
  puts "OUTPUT OK"
else
  puts "#{$failures} check(s) failed"
  exit 1
end
```

- [ ] **Step 2: Run it to verify it fails**

Run: `tools/build.sh >/dev/null && ruby tools/check-output.rb`
Expected: `FAIL publications/index.html exists`, `FAIL 404.html exists` and more. Exit 1.

- [ ] **Step 3: Write the redirect layout, redirect pages and 404**

`_layouts/redirect.html`:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Redirecting…</title>
<meta name="robots" content="noindex">
<meta http-equiv="refresh" content="0; url={{ page.redirect_to | relative_url }}">
<link rel="canonical" href="{{ page.redirect_to | absolute_url }}">
<link rel="icon" type="image/png" sizes="32x32" href="{{ '/assets/img/favicon.png' | relative_url }}">
</head>
<body>
<p>This page has moved to <a href="{{ page.redirect_to | relative_url }}">{{ page.redirect_to | absolute_url }}</a>.</p>
</body>
</html>
```

`publications/index.html`:

```html
---
layout: redirect
redirect_to: /#publications
sitemap: false
---
```

`projects/index.html`:

```html
---
layout: redirect
redirect_to: /#publications
sitemap: false
---
```

`projects/compass/index.html`:

```html
---
layout: redirect
redirect_to: /#publications
sitemap: false
---
```

`blog/index.html`:

```html
---
layout: redirect
redirect_to: /
sitemap: false
---
```

`404.html`:

```html
---
layout: default
title: Page not found
permalink: /404.html
sitemap: false
---
<section class="card notfound">
  <h1><span class="emo" aria-hidden="true">🧭</span> Page not found</h1>
  <p>The page you asked for is not here. It may have moved when this site was redesigned in 2026.</p>
  <p><a class="btn" href="{{ '/' | relative_url }}">← Back to the home page</a></p>
</section>
```

- [ ] **Step 4: Run it to verify it passes**

Run: `tools/build.sh >/dev/null && ruby tools/check-output.rb`
Expected: all `PASS` and `OUTPUT OK`.

- [ ] **Step 5: Commit**

```bash
git add _layouts/redirect.html publications projects blog 404.html tools/check-output.rb
git commit -m "feat: add redirects for old URLs, 404 page, and SEO output gate

Co-Authored-By: <attribution line 1>
Claude-Session: <attribution line 2>"
```

---

### Task 8: Internal and external link gates

**Files:**
- Create: `tools/check-internal.rb`, `tools/check-links.sh`

**Interfaces:**
- Produces:
  - `ruby tools/check-internal.rb` prints `INTERNAL OK` and exits 0, or exits 1.
  - `tools/check-links.sh` exits 1 only for hard failures; 403/429 are warnings.

- [ ] **Step 1: Write `tools/check-internal.rb`**

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# Gate 2a (local): internal links and #fragments resolve, every <img> has alt, and
# every page links a favicon. html-proofer runs the same checks in CI; it cannot be
# installed here (no Ruby dev headers), so this uses the system Nokogiri.
require "nokogiri"
require "uri"

SITE = File.expand_path("../_site", __dir__)
abort "Build the site first: tools/build.sh" unless File.exist?(File.join(SITE, "index.html"))
errors = []
docs = {}
read_doc = ->(file) { docs[file] ||= Nokogiri::HTML(File.read(file)) }

def resolve(site, from_file, path)
  target = path.start_with?("/") ? File.join(site, path) : File.join(File.dirname(from_file), path)
  target = File.expand_path(target)
  File.directory?(target) ? File.join(target, "index.html") : target
end

pages = Dir.glob(File.join(SITE, "**", "*.html"))
pages.each do |file|
  rel = file.delete_prefix("#{SITE}/")
  doc = read_doc.call(file)
  errors << "#{rel}: no <link rel=\"icon\">" unless doc.at('link[rel~="icon"]')
  doc.css("img").each { |img| errors << "#{rel}: <img src=\"#{img['src']}\"> has no alt attribute" unless img.key?("alt") }
  refs = doc.css("a[href]").map { |n| n["href"] } + doc.css("link[href]").map { |n| n["href"] } +
         doc.css("script[src]").map { |n| n["src"] } + doc.css("img[src]").map { |n| n["src"] }
  refs.each do |href|
    next if href.nil? || href.empty?

    begin
      uri = URI.parse(href)
    rescue URI::InvalidURIError
      errors << "#{rel}: unparsable URL #{href}"
      next
    end
    next if uri.scheme || href.start_with?("//") # external: tools/check-links.sh

    target = uri.path.to_s.empty? ? file : resolve(SITE, file, uri.path)
    unless File.exist?(target)
      errors << "#{rel}: broken link #{href}"
      next
    end
    next if uri.fragment.to_s.empty?

    errors << "#{rel}: #{href} points to a missing id" unless read_doc.call(target).at_css("[id=\"#{uri.fragment}\"]")
  end
end

if errors.empty?
  puts "INTERNAL OK (#{pages.size} pages)"
else
  errors.uniq.each { |e| puts "FAIL #{e}" }
  exit 1
end
```

- [ ] **Step 2: Prove it catches a broken link, then run it for real**

```bash
tools/build.sh >/dev/null
echo '<link rel="icon" href="/assets/img/favicon.png"><a href="/nope/">x</a><a href="/#missing">y</a><img src="/assets/img/avatar.png">' > _site/probe.html
ruby tools/check-internal.rb; echo "exit=$?"
rm _site/probe.html
ruby tools/check-internal.rb
```

Expected:
- First run: `FAIL probe.html: broken link /nope/`, `FAIL probe.html: /#missing points to a missing id`, `FAIL probe.html: <img src="/assets/img/avatar.png"> has no alt attribute` and `exit=1`.
- Second run: `INTERNAL OK (6 pages)`.

- [ ] **Step 3: Write `tools/check-links.sh`**

```bash
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
```

Run: `chmod +x tools/check-links.sh && tools/check-links.sh`

Expected: about 40 URLs; `0 failed`. Publisher pages behind bot walls may show `WARN 403` (for example doi.org → ScienceDirect or Springer). Open each WARN URL once in a browser to confirm it shows the right paper, and list them in the Task 10 report.

A `FAIL` means a wrong URL. Fix it in `_data/*.yml` from the spec §4 inventory, and never guess a replacement.

- [ ] **Step 4: Commit**

```bash
git add tools/check-internal.rb tools/check-links.sh
git commit -m "test: add internal and external link gates

Co-Authored-By: <attribution line 1>
Claude-Session: <attribution line 2>"
```

---

### Task 9: Deploy workflow and README

**Files:**
- Replace: `.github/workflows/deploy.yml`
- Create: `README.md`

**Interfaces:**
- Produces:
  - CI runs on every push and on PRs to `main`. It builds, then runs html-proofer.
  - It deploys to `gh-pages` only on push to `main`.

- [ ] **Step 1: Write the failing workflow check**

```bash
ruby -ryaml -e '
w = YAML.load_file(".github/workflows/deploy.yml")
on = w["on"] || w[true]
ok = on.dig("push", "branches") == ["**"] &&
     w.dig("permissions", "contents") == "write" &&
     w.dig("jobs", "build", "steps").any? { |s| s["uses"].to_s.start_with?("peaceiris/actions-gh-pages@v4") && s["if"].to_s.include?("refs/heads/main") } &&
     w.dig("jobs", "build", "steps").any? { |s| s["run"].to_s.include?("htmlproofer _site --disable-external") }
puts(ok ? "WORKFLOW OK" : "WORKFLOW NOT READY"); exit(ok ? 0 : 1)'
```

Expected: `WORKFLOW NOT READY`, because the old al-folio workflow is still in place.

- [ ] **Step 2: Write `.github/workflows/deploy.yml`**

```yaml
name: Build and deploy

on:
  push:
    branches: ["**"]        # every branch builds; only main deploys (see the last step)
  pull_request:
    branches: [main]

permissions:
  contents: write           # needed to push the built site to gh-pages

concurrency:
  group: pages-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true

      - name: Build
        run: bundle exec jekyll build
        env:
          JEKYLL_ENV: production

      - name: Check internal links, images and favicons
        run: |
          gem install html-proofer -v "~> 5.0" --no-document
          htmlproofer _site --disable-external --checks Links,Images,Scripts,Favicon

      - name: Deploy to gh-pages
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./_site
          publish_branch: gh-pages
          # keep_files stays false: the old al-folio files on gh-pages are removed.
          # The action adds .nojekyll so Pages serves _site as-is.
```

- [ ] **Step 3: Write `README.md`**

````markdown
# lizhyun.github.io

Personal academic homepage of Zhiyuan Li — https://lizhyun.github.io

A small Jekyll 4 site. All content lives in `_data/*.yml`; the page itself is
`_layouts/home.html`. Design spec: `docs/superpowers/specs/2026-09-30-homepage-redesign-design.md`.

## Add a paper

1. Make a thumbnail (WebP, at most 800 px wide and 80 KB):
   `cwebp -q 80 -resize 800 0 figure.png -o assets/img/pubs/my-paper.webp`
2. Add an entry to `_data/publications.yml` under its year (newest year first). Copy an
   existing entry. `venue_key` picks the badge color (`neurips icml aaai arxiv nn tnsm eaai apin aamas tpami`);
   `type` is `Conference`, `Journal`, `Preprint`, `Workshop` or `Under review`; links are full `https://` URLs.
3. `selected: true` shows it in the Selected view. `new: true` adds the 🔥 tag — keep it on one paper only.
4. Update the counts in the check command below (`--expect-total`, `--expect-selected`).

## Add a news item

Add it at the top of `_data/news.yml`:

```yaml
- date: "2026-10"          # quoted, "YYYY-MM" or "YYYY"
  emoji: "🎉"
  html: '<a href="https://…">Paper title</a> accepted to …'
```

Move `new: true` to the newest item. Items with `older: true` stay behind "Show older".

## Update the Scholar numbers

Edit `scholar:` in `_data/profile.yml` (`citations`, `h_index`, `updated`).

## Preview locally

One-time setup. This machine's Ruby has no dev headers, so bundler uses the system gems and
pure-Ruby gems go to the user gem directory:

```sh
gem install --user-install --no-document --ignore-dependencies jekyll-seo-tag -v 2.9.1
bundle install --local
(cd tools && npm ci)
```

Then run `bundle exec jekyll serve` and open http://127.0.0.1:4000.

## Run the checks

```sh
tools/build.sh
ruby tools/check-data.rb --expect-total 14 --expect-selected 6
ruby tools/check-internal.rb
ruby tools/check-output.rb
node tools/contrast.mjs
node tools/browser.mjs all
tools/check-links.sh
```

## Deploy

Push to `main`. GitHub Actions builds the site, runs html-proofer, and publishes `_site`
to the `gh-pages` branch, which GitHub Pages serves. Pushes to other branches only build.
````

- [ ] **Step 4: Run the workflow check to verify it passes**

Run the command from Step 1 again.
Expected: `WORKFLOW OK`.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/deploy.yml README.md
git commit -m "ci: build on every push, html-proofer, deploy main to gh-pages; add README

Co-Authored-By: <attribution line 1>
Claude-Session: <attribution line 2>"
```

---

### Task 10: Full verification, owner preview, and release

**Files:**
- No new files. `tools/out/*` is scratch output.

- [ ] **Step 1: Run every gate from a clean build**

```bash
rm -rf _site .jekyll-cache
tools/build.sh
ruby tools/check-data.rb --expect-total 14 --expect-selected 6
tools/test/check-data.test.sh
tools/check-assets.sh
ruby tools/check-internal.rb
ruby tools/check-output.rb
node tools/contrast.mjs
node tools/browser.mjs all
tools/check-links.sh
```

Expected, in order:
- `BUILD OK`
- `DATA OK`
- the self-test passes
- all asset `PASS` lines
- `INTERNAL OK (6 pages)`
- `OUTPUT OK`
- `CONTRAST OK`
- `BROWSER OK`, including `first-load weight … MB (max 1.2 MB …)` as PASS
- `0 failed` from the link check

Any failure: fix it and re-run all of them.

- [ ] **Step 2: Review the four screenshots**

`node tools/browser.mjs screens` wrote the following files. Look at each with the Read tool, cropped with ImageMagick where the page is tall.
- `tools/out/home-1440-light.png`: matches `mockup/D-rich.jpg`, except the spec-mandated differences (no †, COMPASS news wording, working toggle and 🌙 button visible).
- `tools/out/home-1440-dark.png`: every text is readable, and logos and figures sit on white tiles.
- `tools/out/home-390-light.png` and `home-390-dark.png`:
  - the cards stack;
  - the avatar sits above the name;
  - thumbnails are full width;
  - there is no clipped text;
  - there is no horizontal scroll.

Fix and re-run Step 1 for anything wrong.

- [ ] **Step 3: Owner preview**

```bash
for f in home-1440-light home-1440-dark home-390-light home-390-dark; do
  convert "tools/out/$f.png" -quality 85 "tools/out/$f.jpg"
done
```

Send the four JPGs to the owner with SendUserFile. Tell them they can run `! bundle exec jekyll serve` to click through it at http://127.0.0.1:4000. List any `WARN` links from Task 8 that need a manual look. Wait for the owner's approval; apply requested changes and repeat Steps 1–3.

- [ ] **Step 4: Push the branch (only on the owner's go-ahead)**

```bash
git status --short          # expect clean, papers/ not listed
git log --oneline main..redesign-2026
git push -u origin redesign-2026
```

The branch push triggers the build-only CI run. Tell the owner the Actions URL: `https://github.com/LiZhYun/LiZhYun.github.io/actions`.

Wait for it to pass. If `bundle install` fails in CI (for example a native gem pinned in the lockfile will not compile on Ruby 3.3), fix it:
1. Run `bundle lock --local --update <gem>`, or pin the gem in `Gemfile`.
2. Commit and push again.
3. Report what changed.

- [ ] **Step 5: Release (only on the owner's go-ahead)**

```bash
git checkout main
git merge --ff-only redesign-2026
git push origin main
```

Wait for the `main` workflow run to finish. Then verify the live site:

```bash
curl -s https://lizhyun.github.io/ | grep -o '<title>[^<]*</title>'
curl -s -o /dev/null -w '%{http_code}\n' https://lizhyun.github.io/assets/pdf/Li_Zhiyuan_CV_zh.pdf
curl -s -o /dev/null -w '%{http_code}\n' https://lizhyun.github.io/blog/2024/postdoc/
curl -s https://lizhyun.github.io/publications/ | grep -o 'url=[^"]*'
```

Expected:
- `<title>Zhiyuan Li (李志圆)</title>`
- `200`
- `404`
- `url=/#publications`

GitHub Pages can take a minute or two to refresh. Report the live URL to the owner.
