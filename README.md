# lizhyun.github.io

Personal academic homepage of Zhiyuan Li — https://lizhyun.github.io

A small Jekyll 4 site. All content lives in `_data/*.yml`; the page itself is
`_layouts/home.html`. Design spec: `docs/superpowers/specs/2026-09-30-homepage-redesign-design.md`.

## Add a paper

1. Make a thumbnail (WebP, at most 800 px wide and 80 KB):
   `cwebp -q 80 -resize 800 0 figure.png -o assets/img/pubs/my-paper.webp`
2. Add an entry to `_data/publications.yml` under its year (newest year first). Copy an
   existing entry. `venue_key` picks the badge color (`neurips icml aaai arxiv nn tnsm eaai apin aamas tpami bmvc ijcnn`);
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

One-time setup, on a machine with Ruby development headers (the normal case):

```sh
bundle install
(cd tools && npm ci)
```

**Note, for this machine specifically:** its Ruby has no dev headers, so native gems can't
compile here. Bundler falls back to the system gems, and the one pure-Ruby gem it's missing
goes to the user gem directory instead:

```sh
gem install --user-install --no-document --ignore-dependencies jekyll-seo-tag -v 2.9.1
bundle install --local
(cd tools && npm ci)
```

Then run `bundle exec jekyll serve` and open http://127.0.0.1:4000.

## Run the checks

```sh
tools/build.sh
ruby tools/check-data.rb --expect-total 16 --expect-selected 6
ruby tools/check-internal.rb
ruby tools/check-output.rb
node tools/contrast.mjs
node tools/browser.mjs all
tools/check-links.sh
tools/check-assets.sh
tools/test/check-data.test.sh
```

CI (`.github/workflows/deploy.yml`) also runs `check-data.rb` (structure only, no
`--expect-*` counts) and `contrast.mjs` on every push, alongside the build and html-proofer.

## Deploy

Push to `main`. GitHub Actions builds the site, runs html-proofer, and publishes `_site`
to the `gh-pages` branch, which GitHub Pages serves. Pushes to other branches only build.
