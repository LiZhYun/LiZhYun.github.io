# Homepage redesign — design spec

- **Date:** 2026-09-30
- **Owner:** Zhiyuan Li (GitHub `LiZhYun`)
- **Repo:** `LiZhYun.github.io`, branch `redesign-2026`
- **Status:** approved by the owner on 2026-09-30 (revision 2, which includes fixes from an independent fact-check and an implementer review, plus the no-corresponding-author-marks change).

## 1. Goal

Replace the outdated al-folio site with a single, polished home page. The page shows the Sept 2026 CV content and the 14 papers listed in that CV. It uses the approved "D+" design: the wangrongsheng.github.io layout made richer with emoji, logos, highlights, colored venue badges and a light Apple-style finish, while staying professional.

Other co-authored works are left out on purpose and are reachable through the Google Scholar link. These are a Scholar-listed dialogue-generation paper and arXiv 2605.31508, 2605.30211 and 2309.14792.

**Visual source of truth:** `docs/superpowers/specs/2026-09-30-homepage-redesign/mockup/index.html` and its screenshot `mockup/D-rich.jpg`. It covers a desktop light theme only. Where this spec and the mockup disagree, this spec wins. The mockup's fixed pixel widths are not to be copied (see §6).

### Decisions (confirmed by the owner)

| Topic | Decision |
|---|---|
| Language | English site. 李志圆, with pinyin ruby Lǐ Zhì Yuán, in the hero. A "中文简历" chip links to the Chinese CV. No bilingual toggle. |
| Chinese CV | `assets/pdf/Li_Zhiyuan_CV_zh.pdf` is published as-is. It includes birth year and month, native place (籍贯), mobile number and WeChat ID. This is the owner's explicit choice. It is linked but left out of `sitemap.xml`. |
| Pages | Home page only. The Publications section has a **Selected / All** toggle and Google Scholar links instead of a separate publications page. |
| Project links | A 🌐 Project button on every paper with a project page. That includes COMPASS, whose page is still anonymized (see §10). |
| Photo | The avatar image `cropped_circle_image.png`, a hand-drawn figure already cut to a circle. Not a real photo. |
| Style | D+ layout. No ribbon background: a soft glow and a dot grid at the top only, and a frosted navbar. Emoji on headings, news items and link buttons. |
| Supervision | Not on the site; it stays in the CV only. |
| NeurIPS 2026 | Both NeurIPS 2026 papers are accepted. The owner confirmed this; the retargeting paper was not yet in the neurips.cc data. |
| Corresponding author | Not marked anywhere on the site. The owner is corresponding author on all his first-author papers, so a † would add nothing. |
| Build | A small custom Jekyll site (not al-folio), with content in `_data/*.yml`. |

## 2. Page anatomy (top to bottom)

1. **Navbar:** frosted glass, sticky. Left: "Zhiyuan Li 李志圆". Right: Home (`/`), Publications (`/#publications`), a divider, then the theme button (§6).
2. **Hero card:**
   - The name in Lato 300 at about 40px, with the 李志圆 ruby.
   - Subtitle: "🤖 Postdoctoral Researcher @ Aalto Robot Learning Lab, Aalto University" and "📍 Espoo, Finland".
   - Two bio paragraphs.
   - A circular avatar at right, about 150px.
   - Three inner boxes: **📬 Social & Contacts** (chips), **🔬 Research Interests** (4 chips) and **✨ Highlights** (4 chips).
3. **Two-column card.** Left: 🎓 Education and 💼 Experience, as rows with a logo tile, the institution, a grey role line and italic dates. Right: 🏆 Honors & Awards, 🤝 Service and 🧑‍🏫 Teaching.
4. **📰 News card:** rows grouped by year. Each row has an emoji, the text and a date. "Show older" is described in §6.
5. **Publications card** (`id="publications"`):
   - The header holds the title, the Scholar badges (🎓 Citations | 91, h-index | 6), the Selected/All toggle and "Google Scholar →".
   - Each row has:
     - a thumbnail about 200×134 (contain, 3:2), with a "🔥 New" tag on the entry marked `new: true`;
     - the title;
     - the authors, with **Zhiyuan Li** bold (no corresponding-author marks);
     - a colored venue badge, an outline type pill and an optional "🏆 Oral" pill;
     - a grey one-sentence tldr;
     - pill buttons in this order, only those present: 📄 Paper · 📜 arXiv · 📖 Open access · 💻 Code · 🌐 Project.
   - Rows without `thumb` use a compact text-only layout.
   - Card footer: "All publications on Google Scholar »".
6. **Footer** (outside the cards): "Last updated: <Mon YYYY of the build>" at left and "© <build year> Zhiyuan Li" at right.

## 3. Files and structure

```
index.html                   front matter: layout: home, description, image, seo (§7)
_config.yml                  title, url, author, lang, social, liquid strictness, defaults, exclude
Gemfile / Gemfile.lock       jekyll ~> 4.4, jekyll-seo-tag, jekyll-sitemap; group :test html-proofer ~> 5.0
_layouts/default.html        <head> (fonts, seo, icons, theme script), navbar, footer
_layouts/home.html           hero, two-column card, news, publications
_layouts/redirect.html       standalone (not default.html); see §8
_includes/pub-row.html       one publication row (thumbnail or compact)
_includes/news-row.html      one news row
_includes/timeline-row.html  one education/experience row
_includes/chip.html          one chip (icon, label, href, lang)
_includes/icons/*.svg        scholar, github, orcid, email, doc (inline SVG)
_data/profile.yml            see §5
_data/highlights.yml         emoji, bold, rest
_data/news.yml               see §5
_data/publications.yml       see §4
_data/education.yml          institution, logo, degree, dates
_data/experience.yml         institution, logo, role, note, dates
_data/awards.yml             emoji, title, org, year
_data/service.yml            label, text
_data/teaching.yml           html
assets/css/site.css          light and dark tokens, components, responsive rules
assets/js/site.js            toggle, show older, theme; no libraries
assets/img/avatar.png        480px, from cropped_circle_image.png
assets/img/favicon.png       32×32
assets/img/apple-touch-icon.png  180×180, avatar on an opaque #ffffff square
favicon.ico                  32×32, at the site root
assets/img/logos/            aalto.png, uestc.png, ncepu.png (128px)
assets/img/pubs/*.webp       thumbnails, ≤ 800px wide, ≤ 80 KB
assets/pdf/                  Li_Zhiyuan_CV.pdf (Sept 2026), Li_Zhiyuan_CV_zh.pdf
publications/index.html      redirect → /#publications
projects/index.html          redirect → /#publications
projects/compass/index.html  redirect → /#publications
blog/index.html              redirect → /
404.html                     "Page not found" in the site's look, with a link home
README.md                    how to add a paper or news item, preview, run checks
tools/                       build.sh, check-*.{rb,sh}, make-assets.sh, contrast.mjs, browser.mjs, package.json (§9)
.gitignore                   _site/, .jekyll-cache/, .bundle/, vendor/, papers/, .sass-cache/, node_modules/, tools/out/
.github/workflows/deploy.yml §7
docs/                        specs, plans, mockup, the original avatar file
```

- There is no `robots.txt` in the repo; jekyll-sitemap generates one with the sitemap line.
- `_config.yml` `exclude`: `docs/`, `papers/`, `tools/`, `README.md`, `Gemfile`, `Gemfile.lock`, `vendor/`, `node_modules/`.
- No jQuery, Bootstrap, MathJax or jekyll-scholar.
- **URLs:** every internal URL is root-relative through `relative_url`, e.g. `{{ '/assets/css/site.css' | relative_url }}`. That way pages also work from 404.html and the redirect pages.
- **Anchors:** anchor targets get `scroll-margin-top: 72px`, so the sticky navbar doesn't cover them.

## 4. Publications data: `_data/publications.yml`

| Field | Type | Notes |
|---|---|---|
| `title` | string | Title as the authors wrote it in the paper. Title case is allowed. |
| `authors` | list | Full names in order. "Zhiyuan Li" is rendered bold. |
| `venue` | string | Badge text, e.g. `NeurIPS 2026`. |
| `venue_key` | enum | `neurips` `icml` `aaai` `arxiv` `nn` `tnsm` `eaai` `apin` `aamas` `tpami` |
| `type` | enum | `Conference` `Journal` `Preprint` `Workshop` `Under review` |
| `award` | string, optional | e.g. `Oral` |
| `year` | int | Also the All-view group heading. |
| `selected` | bool | Shown in the Selected view. |
| `new` | bool, optional | The "🔥 New" tag. At most one entry, and it must have `thumb`. |
| `thumb` | string, optional | A file in `assets/img/pubs/`. Absent means a compact row. |
| `tldr` | string | One sentence, factual, taken from the paper. |
| `links` | map | Optional `paper`, `arxiv`, `oa`, `code`, `project`. Values are full `https://` URLs; arXiv as `https://arxiv.org/abs/<id>`. |

**Link targets**
- The **primary link** is the first present of `paper`, `arxiv`, `project`, `code`.
- The title links to the primary link. The thumbnail links to `project`, else to the primary link.
- A paper named in a news item links to its primary link.

**Order.** Entries are grouped by year, newest year first. Within a year they follow the inventory order below. The list order is the display order.

**Badge colors.** Text is white; the colors are the same in both themes:

| key | color |
|---|---|
| neurips | #3b0f70 |
| icml | #1e3a8a |
| aaai | #0d7c72 |
| arxiv | #b31b1b |
| nn | #166534 |
| tnsm, tpami | #00629b |
| eaai | #9a3412 |
| apin | #1f4e79 |
| aamas | #6b21a8 |

### Content inventory: the 14 papers

All links were verified on 2026-09-30.

| # | Paper — authors | Venue · type | Sel | Links | Thumbnail |
|---|---|---|---|---|---|
| 1 | Why Cross-Skeleton Retargeting Is Non-Identifiable: Structural Limits of Generative Motion Models — Zhiyuan Li, Wenyan Yang, Pekka Marttinen, Joni Pajarinen | NeurIPS 2026 · Conference · `new` | ✓ | | paper https://arxiv.org/abs/2609.37297 · code https://github.com/LiZhYun/NeurIPS2026-Cross-Skeleton-Retargeting · project https://cross-skeleton-retargeting.netlify.app/ | mockup `retarget_panorama.jpg` |
| 2 | Sparsely Supervised Diffusion — Wenshuai Zhao, Zhiyuan Li, Yi Zhao, Mohammad Hassan Vali, Martin Trapp, Joni Pajarinen, Juho Kannala, Arno Solin | NeurIPS 2026 · Conference | | | paper https://arxiv.org/abs/2602.02699 · project https://sites.google.com/view/sparsely-supervised-diffusion/home | Figure 2 (method overview) from the arXiv e-print; owner approves |
| 3 | Rethinking Temporal Consistency in Video Object-Centric Learning: From Prediction to Correspondence — Zhiyuan Li, Rongzhen Zhao, Wenyan Yang, Wenshuai Zhao, Pekka Marttinen, Joni Pajarinen | ICML 2026 · Conference | ✓ | paper https://proceedings.mlr.press/v306/li26js.html · arxiv https://arxiv.org/abs/2605.03650 · code https://github.com/LiZhYun/ICML2026-RethinkingOCL · project https://magenta-sherbet-85b101.netlify.app/ | mockup `rocl_fig1_left.jpg` |
| 4 | Closed-Loop Vision-Language Planning for Multi-Agent Coordination — Zhiyuan Li, Wenshuai Zhao, Joni Pajarinen | SE@AAMAS 2026 · Workshop | | | paper https://arxiv.org/abs/2502.10148 · code https://github.com/LiZhYun/COMPASS-SE-AAMAS · project https://lizhyun.github.io/COMPASS/ | `figs/compass.pdf` (COMPASS zip) |
| 5 | Bridging the Embodiment Gap: Disentangled Cross-Embodiment Video Editing — Zhiyuan Li, Wenyan Yang, Wenshuai Zhao, Yue Ma, Yuanpeng Tu, Pekka Marttinen, Joni Pajarinen | arXiv 2026 · Preprint | ✓ | paper https://arxiv.org/abs/2605.03637 · code https://github.com/LiZhYun/EgoXEdit | mockup `egox.jpg` |
| 6 | Do We Really Need the Default Recipe for Video Object-Centric Learning? — Zhiyuan Li, Rongzhen Zhao, Wenyan Yang, Wenshuai Zhao, Arno Solin, Juho Kannala, Pekka Marttinen, Joni Pajarinen | IEEE TPAMI · Under review | | ✓ | code https://github.com/LiZhYun/ICML2026-RethinkingOCL (the manuscript's own code link) | `figures/fig1_study_overview_v15.pdf` (TPAMI zip) |
| 7 | Learning Progress Driven Multi-Agent Curriculum — Wenshuai Zhao, Zhiyuan Li, Joni Pajarinen | ICML 2025 · Conference | | | paper https://proceedings.mlr.press/v267/zhao25o.html · arxiv https://arxiv.org/abs/2205.10016 · code https://github.com/wenshuaizhao/spmarl · project https://wenshuaizhao.github.io/spmarl/ | Figure 1 from the arXiv e-print; owner approves |
| 8 | AgentMixer: Multi-Agent Correlated Policy Factorization — Zhiyuan Li, Wenshuai Zhao, Lijun Wu, Joni Pajarinen | AAAI 2025 · Conference · Oral | ✓ | | paper https://doi.org/10.1609/aaai.v39i17.34048 · arxiv https://arxiv.org/abs/2401.08728 | mockup `agentmixer.jpg` |
| 9 | Adaptive graph attention networks with interactive learning for attributed graph clustering — Weiwei Duan, Luping Ji, Lijun Wu, Qi Deng, Zhiyuan Li | EAAI 2025 · Journal | | | paper https://doi.org/10.1016/j.engappai.2025.111574 · code https://github.com/MrDec/AGAT-IL | none (compact) |
| 10 | Multi-agent neighborhood coordinated and holistic optimized actor-critic framework for adaptive traffic signal control — Qi Deng, Lijun Wu, Zhiyuan Li, Kaile Su, Wei Wu, Weiwei Duan | Applied Intelligence 2025 · Journal | | | paper https://doi.org/10.1007/s10489-025-06758-x · oa https://research.aalto.fi/en/publications/multi-agent-neighborhood-coordinated-and-holistic-optimized-actor/ | none (compact) |
| 11 | Optimistic Multi-Agent Policy Gradient — Wenshuai Zhao, Yi Zhao, Zhiyuan Li, Juho Kannala, Joni Pajarinen | ICML 2024 · Conference | | | paper https://proceedings.mlr.press/v235/zhao24v.html · arxiv https://arxiv.org/abs/2311.01953 · code https://github.com/wenshuaizhao/optimappo · project https://wenshuaizhao.github.io/optimappo/ | Figure 1 from the arXiv e-print; owner approves |
| 12 | Backpropagation Through Agents — Zhiyuan Li, Wenshuai Zhao, Lijun Wu, Joni Pajarinen | AAAI 2024 · Conference | ✓ | | paper https://doi.org/10.1609/aaai.v38i12.29277 · arxiv https://arxiv.org/abs/2401.12574 · code https://github.com/LiZhYun/BackPropagationThroughAgents | mockup `bpta.jpg` |
| 13 | Coordination as Inference in Multi-Agent Reinforcement Learning — Zhiyuan Li, Lijun Wu, Kaile Su, Wei Wu, Yulin Jing, Tong Wu, Weiwei Duan, Xiaofeng Yue, Xiyi Tong, Yizhou Han | Neural Networks 2024 · Journal | ✓ | paper https://doi.org/10.1016/j.neunet.2024.106101 · code https://github.com/LiZhYun/DMS | mockup `dms.jpg` |
| 14 | Online Coordinated NFV Resource Allocation via Novel Machine Learning Techniques — Zhiyuan Li, Lijun Wu, Xiangyun Zeng, Xiaofeng Yue, Yulin Jing, Wei Wu, Kaile Su | IEEE TNSM 2023 · Journal | | ✓ | paper https://doi.org/10.1109/TNSM.2022.3205900 | current `assets/img/publication_preview/OCRA.jpg` |

**Thumbnail pipeline**
- **Mockup images:** the files in `mockup/assets/` are converted with `cwebp -q 80 -resize 800 0`, as is OCRA.jpg.
- **PDF figures** (papers 4, 6): rasterized with `pdftoppm -png -r 200 -singlefile`, trimmed, then converted the same way.
- **Papers 2, 7, 11:** their arXiv e-prints (`https://arxiv.org/e-print/<id>`) are downloaded into `papers/`, and the named figure is extracted. The owner approves these three before the preview; any he rejects become compact rows.
- **Limit:** every output is ≤ 800px wide and ≤ 80 KB.

**tldrs** (one sentence each):
- **1:** "Under standard generative objectives, sparse multi-body motion data cannot pin down which source-to-target map a cross-skeleton retargeting model learns, so the paper proposes Source-Instance Fidelity (SIF) to test whether generated motion actually follows its source clip."
- **3:** "Learned temporal predictors in video object-centric models mostly just keep slot indices stable, so seeding slots from saliency peaks in frozen DINOv2 features and Hungarian-matching them across frames does the same job with no learned temporal parameters."
- **4:** "Each agent plans with a vision-language model in a closed loop, writes and reuses code skills, and shares observations through multi-hop communication; evaluated on SMACv2."
- **5:** "Turns an egocentric human manipulation video into a robot demonstration video by separating task and embodiment codes that condition a frozen video diffusion model."
- **6:** "A controlled study showing that neither a learned temporal predictor nor a frozen backbone is always necessary for video object-centric learning: what matters is how object identity is carried across frames, and whether an adapted encoder stays tied to a frozen pretrained feature target."
- **8:** "A centralized joint policy correlates agents' actions, while a mode-consistency constraint keeps it executable by decentralized, partially observing agents."
- **12:** "Later agents in an auto-regressive multi-agent policy send gradients back to earlier agents through their actions."
- **13:** "Independent learners infer teammates' intentions from observed actions and choose whom to coordinate with — no centralized critic, no communication."
- **14:** "A parallel multi-agent deep RL framework that performs all three stages of NFV resource allocation jointly and online by generating an embedding subgraph per request."
- **2, 7, 9, 10, 11:** one sentence each, written from the official abstract, with no claims beyond it.

**Corrections relative to the Sept 2026 CV.** The site uses the official record:
1. ICML'24 title: "Optimistic Multi-Agent Policy Gradient".
2. EAAI: 2025.
3. COMPASS: SE@AAMAS 2026 Workshop, not the main conference.
4. OCRA: TNSM 2023, the issue year.
5. Applied Intelligence is named as "Applied Intelligence", not by its subtitle.

## 5. Other data

**`profile.yml`**

- **Identity:**
  - `name`: Zhiyuan Li
  - `name_zh`: 李志圆
  - `pinyin`: [Lǐ, Zhì, Yuán]
  - `role`: Postdoctoral Researcher
  - `org`: Aalto Robot Learning Lab, Aalto University
  - `location`: Espoo, Finland
  - `email`: zhiyuan.li@aalto.fi
- **`bio[]`:** HTML strings, the two approved mockup paragraphs. Inline links:
  - Aalto Robot Learning Lab → https://rl.aalto.fi/
  - Joni Pajarinen → https://scholar.google.com/citations?user=-2fJStwAAAAJ
- **`chips[]`** (icon, label, href, lang):

  | Label | Link |
  |---|---|
  | `zhiyuan.li(at)aalto.fi` (mono) | `mailto:zhiyuan.li@aalto.fi` |
  | Google Scholar | https://scholar.google.com/citations?user=1GYbhX0AAAAJ |
  | GitHub | https://github.com/LiZhYun |
  | ORCID | https://orcid.org/0000-0002-1804-3485 |
  | CV | `/assets/pdf/Li_Zhiyuan_CV.pdf` |
  | 中文简历 (`lang: zh`) | `/assets/pdf/Li_Zhiyuan_CV_zh.pdf` |

- **`interests[]`** (icon, label): Multi-Agent Systems, Reinforcement Learning, Robotics, Foundation Models.
- **`scholar`:** `{citations: 91, h_index: 6, updated: 2026-09-30}`, updated by hand. `updated` is shown as the badges' tooltip: "Google Scholar, as of 30 Sep 2026".

**`highlights.yml`**
- 🧑‍⚖️ **Area Chair** · ICLR 2027
- 🎤 **Oral** · AAAI 2025
- 📄 **2 papers** · NeurIPS 2026
- 🧑‍🏫 **Head TA** · Aalto RL course (243 students)

**`news.yml`**
- **Fields:** `date` (a quoted string, `"YYYY-MM"` or `"YYYY"`), `emoji`, `html`, `older` (bool) and `new` (bool, at most one).
- **Order:** list order is display order.
- **Group year:** `date | slice: 0, 4`.
- **Shown date:** `Mon YYYY`, built from a month-name array indexed by `date | slice: 5, 2`. When there is no month, only `YYYY`.
- **Never** apply Liquid `date` or `date_to_string` to these values.

Current items:

| Date | Emoji | Text | New |
|---|---|---|---|
| 2026-09 | 🎉 | Two papers accepted to NeurIPS 2026: cross-skeleton motion retargeting, and Sparsely Supervised Diffusion. | yes |
| 2026 | 🧑‍⚖️ | Serving as Area Chair for ICLR 2027. | |
| 2026-05 | 🎉 | Rethinking Temporal Consistency in Video Object-Centric Learning accepted to ICML 2026. | |
| 2026-05 | 🎤 | COMPASS accepted as a lightning talk at the SE@AAMAS 2026 workshop in Paphos, Cyprus. | |
| 2025-05 | 🎉 | Learning Progress Driven Multi-Agent Curriculum accepted to ICML 2025. | |
| 2024-12 | 🏆 | AgentMixer accepted to AAAI 2025 as an oral presentation. | |
| 2024-08 | 🏠 | Joined the Aalto Robot Learning Lab as a postdoctoral researcher. | |

Older items (`older: true`):

| Date | Emoji | Text |
|---|---|---|
| 2024-05 | 🎉 | Optimistic Multi-Agent Policy Gradient accepted to ICML 2024. |
| 2024-01 | 🎉 | Coordination as Inference in MARL accepted by Neural Networks. |
| 2023-12 | 🎉 | Backpropagation Through Agents accepted to AAAI 2024. |
| 2022-11 | ✈️ | Began a one-year visit at the Aalto Robot Learning Lab. |
| 2022-09 | 🎉 | OCRA accepted by IEEE Transactions on Network and Service Management. |

**Education**
- UESTC: Ph.D. in Computer Science and Technology, Sep 2019 – Jul 2024.
- NCEPU: B.S. in Computer Science and Technology, Sep 2015 – Jul 2019.

**Experience**
- Aalto Robot Learning Lab, Aalto University: Postdoctoral Researcher, hosted by Prof. Joni Pajarinen, Aug 2024 – Present.
- Aalto University: Visiting Ph.D. Researcher (CSC-funded), Nov 2022 – Dec 2023.

**Awards**
- 🏅 China Scholarship Council (CSC) Scholarship, 2022
- 🎖️ Academic Scholarship, UESTC, 2019–2022
- 🏅 Honorable Mention, Mathematical Contest in Modeling (MCM), 2017

**Service:** Area Chair: ICLR 2027. Reviewer: NeurIPS, ICML, ICLR, AAAI, ECCV, AAMAS.

**Teaching:** Main teaching assistant, **ELEC-E8125 Reinforcement Learning**, Aalto University. 243 students; coordinated a 12-person TA team.

**Logos**
- Aalto `A!` mark: Wikimedia, public domain.
- UESTC and NCEPU emblems: Wikimedia, non-free logos. Used only to identify the owner's own affiliations.

## 6. Behavior

**Publications Selected/All**
- **Render once:** publications render once, in data order, as a single list of `<article class="pub">`. Before the first row of each year there is a `<h3 class="pub-year">`, computed with `group_by: "year"`.
- **Server HTML:** puts `hidden` on every non-selected row and on every year heading. `site.css` has `[hidden]{display:none !important}`.
- **Controls:** a two-button group with `aria-pressed`, labeled "Selected" and "All N" (N computed). It renders `hidden`, and `site.js` un-hides it. Without JS the page shows the 6 selected rows and the Google Scholar links.
- **All:** un-hides every row and year heading, and retitles the card from "📝 Selected Publications" to "📝 Publications". **Selected** reverses this.
- **Tags in both views:** the 🔥 New tag belongs to its row.
- **Images:** hidden rows' images use `loading="lazy"`, so they are not fetched while hidden.

**News "Show older"**
- **Hidden older items:** older items render inside their year group with `hidden`. A year group whose items are all older is itself `hidden`.
- **Button:** "Show older" renders `hidden` and is un-hidden by `site.js`. Clicking it un-hides everything and removes the button.
- **NEW pill:** shown on the item with `new: true`.

**Theme**
- **Light:** light tokens sit on `:root`.
- **Dark:** dark tokens are declared in two places, `@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){…}}` and `:root[data-theme="dark"]{…}`. So the OS setting works without JS.
- **Inline `<head>` script:** sets `data-theme` only if `localStorage.theme` is `"light"` or `"dark"`, inside try/catch.
- **Button:** shows 🌙 when the effective theme is light and ☀️ when it is dark. A click applies the opposite theme and stores it. It renders `hidden`; `site.js` un-hides it and sets `aria-label="Switch to dark theme"` or `"… light theme"`.
- **Tokens:** every color in `site.css` is a custom property in the light and dark token blocks. That covers ground, card, border, text, muted, accent, box and chip backgrounds, navbar glass, the type, Oral, 🔥 New and NEW pills, glow, dots and shadows.
- **Always white:** venue badge colors (§4), logo tiles, the avatar ring and thumbnail frames keep `#ffffff` in both themes. The logos are black or navy on transparent, and the figures assume a white ground.

**Layout and responsiveness**
- **Widths:**
  - Cards, the navbar's inner row and the footer use `width: min(1110px, 100% - 48px)`.
  - The page, dot grid and glows are full width, with `overflow-x: clip` on the page wrapper.
  - Never the mockup's fixed 1440px or 1110px. No horizontal scroll at any width from 320px.
- **≥ 1024px:** as in the mockup.
- **< 1024px:**
  - The two-column card becomes one column.
  - The hero avatar moves above the name.
  - The publications header wraps: row 1 is the title and badges, row 2 is the toggle at left and "Google Scholar →" at right.
- **< 640px:**
  - Thumbnails go full width above the text.
  - Chips wrap.
  - The badges drop below the title.
  - News rows lose the year column (the year becomes a small heading) and each date moves under its text.
  - The navbar shows the name, Publications and the theme button; Home is hidden.

**Motion:** cards lift 2px on hover, publication rows tint and thumbnails scale to 1.03. All motion is off under `prefers-reduced-motion`.

**Fonts** (in `<head>`)
- Two preconnects: `fonts.googleapis.com`, and `fonts.gstatic.com` with `crossorigin`.
- `https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,300;0,400;0,700;1,400&family=JetBrains+Mono:wght@400&display=swap`
- `https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400&text=%E6%9D%8E%E5%BF%97%E5%9C%86%E4%B8%AD%E6%96%87%E7%AE%80%E5%8E%86&display=swap`. The `text=` value lists every CJK character the page renders (today 李志圆中文简历). `text=` applies to all families in a request, which is why this is a separate link.
- **No emoji web font.** `--emoji: "Apple Color Emoji","Segoe UI Emoji","Noto Color Emoji",sans-serif` is used by `.emo`, and `--sans: "Lato","Helvetica Neue",Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Noto Color Emoji"`.

**Icons**
- `favicon.png` (32), `apple-touch-icon.png` (180) and `/favicon.ico` at the root.
- `<link rel="icon" type="image/png" sizes="32x32" …>` and `<link rel="apple-touch-icon" sizes="180x180" …>`.

## 7. Build, SEO and deploy

**Local setup.** Local Ruby 3.2 has no development headers, so native gems cannot be compiled here.
1. `rm -f Gemfile.lock`. The old lockfile is root-owned but the directory is user-owned, so no sudo is needed.
2. Install the one missing pure-Ruby gem into the user gem directory: `gem install --user-install --no-document --ignore-dependencies jekyll-seo-tag -v 2.9.1`.
3. `bundle lock --local`, `bundle lock --local --add-platform x86_64-linux`, `bundle install --local`. This resolves against the system-installed gems.

The new `Gemfile.lock` is committed. It is resolved on local Ruby 3.2 and must install unchanged on CI Ruby 3.3. html-proofer is not in the Gemfile, because it needs native gems; CI installs it separately.

**`_config.yml`**

| Key | Value |
|---|---|
| `title` | "Zhiyuan Li (李志圆)" |
| `url` | https://lizhyun.github.io |
| `author` | Zhiyuan Li |
| `lang` | en |
| `social` | `{name: Zhiyuan Li, links: [Scholar, GitHub, ORCID URLs]}` |
| `liquid` | `{error_mode: strict, strict_filters: true}` |
| `plugins` | `[jekyll-seo-tag, jekyll-sitemap]` |
| `defaults` | `sitemap: false` for `assets/pdf/Li_Zhiyuan_CV_zh.pdf` and for every redirect page |

- **No `description` key in `_config.yml`:** seo-tag would append it to the home title.
- **`index.html` front matter:** `layout: home`, `description: "Postdoctoral researcher at Aalto University working on multi-agent reinforcement learning, robotics and foundation models."`, `image: /assets/img/avatar.png`, and `seo: {type: Person, name: Zhiyuan Li}`.
- **Result:** the home `<title>` is exactly "Zhiyuan Li (李志圆)", and the JSON-LD is `@type: Person` with `sameAs` from `social.links`.
- **404.html:** sets `title: Page not found`.

**`.github/workflows/deploy.yml`**
- **Triggers:**
  - `on: {push: {branches: ["**"]}, pull_request: {branches: [main]}}`. Every branch builds, so a branch push rehearses CI before merging; only `main` deploys.
  - `permissions: {contents: write}`
  - `concurrency: {group: pages, cancel-in-progress: true}`
- **Steps:**
  - `actions/checkout@v4`
  - `ruby/setup-ruby@v1` (`ruby-version: '3.3'`, `bundler-cache: true`)
  - `bundle exec jekyll build` with `JEKYLL_ENV=production`
  - `gem install html-proofer -v "~> 5.0"`, then `htmlproofer _site --disable-external --checks Links,Images,Scripts,Favicon`
- **Deploy step:**
  - Only runs when `github.event_name == 'push' && github.ref == 'refs/heads/main'`.
  - Uses `peaceiris/actions-gh-pages@v4` with `github_token: ${{ secrets.GITHUB_TOKEN }}`, `publish_dir: ./_site`, `publish_branch: gh-pages`.
  - `keep_files` stays false (the default), so old al-folio files on `gh-pages` are removed, including the mintty screenshot and the raw `_pages/`.
  - The action adds `.nojekyll`, so Pages serves the built files as-is. Don't set `enable_jekyll`.
- **No settings change:** Pages keeps serving `gh-pages`.
- **Nothing is pushed** until the owner approves the local preview.

## 8. Cleanup, redirects and privacy

**Delete**
- **Old content:** `_posts/`, `_pages/`, `_projects/`, `_bibliography/`, the old `_data/*` files and the old `blog/index.html` (replaced by a redirect).
- **Theme code:** `_includes/*` and `_layouts/*` (replaced), `_sass/`, `_plugins/`.
- **Assets:**
  - Scripts and styles: `assets/js/*`, `assets/css/main.scss`.
  - Fonts: `assets/fonts/`, the commercial TT Norms Pro.
  - Demos and samples: `assets/plotly/`, `assets/bibliography/`.
  - Images: `assets/img/prof_pic.jpg`, `assets/img/favicon.ico`, and `assets/img/publication_preview/` (after OCRA.jpg is converted).
  - `assets/img/cropped_circle_image.png`, which moves to `docs/superpowers/specs/2026-09-30-homepage-redesign/` and is kept but not deployed.
- **Root and tooling:** `bin/`, `Dockerfile`, `docker-compose.yml`, `docker-local.yml`, `.all-contributorsrc`, `CONTRIBUTING.md`, al-folio's `LICENSE`, `.pre-commit-config.yaml`, `compile-git-with-openssl.sh`, `mintty.2023-05-30_15-16-35.png`.
- **GitHub config:** `.github/FUNDING.yml`, `.github/stale.yml`, `.github/ISSUE_TEMPLATE/`, and the workflows `deploy-image.yml` and `deploy-docker-tag.yml`.

This removes the polyfill.io script, the postdoc-application post, the hostname screenshot and the other researcher's software page.

**Redirects**
- `/publications/`, `/projects/` and `/projects/compass/` redirect to `/#publications`. `/blog/` redirects to `/`.
- These old URLs are dropped on purpose and get the 404 page: `/blog/2024/`, `/blog/2024/postdoc/`, `/blog/tag/postdoc/`, `/blog/category/postdoc/`, `/feed.xml`.
- `_layouts/redirect.html` is standalone. It emits `<meta http-equiv="refresh" content="0; url=…">`, one `<link rel="canonical">`, `<meta name="robots" content="noindex">` and a visible fallback link.

**Commit:** the Sept 2026 English CV, the Chinese CV, the avatar, logos, thumbnails, the site files, the tools, and this spec with its mockup. `papers/` is gitignored and never committed.

**Git:** all work goes on `redesign-2026`. Commit only with the owner's approval; push only on the owner's go-ahead. Old history is not rewritten.

## 9. Quality gates

These must pass before the owner sees the preview. Scripts live in `tools/` and write to `tools/out/`.

1. **Build:** `JEKYLL_ENV=production bundle exec jekyll build --strict_front_matter 2>&1 | tee tools/out/build.log` exits 0, and `grep -iE 'warn|deprecat|error' tools/out/build.log` prints nothing.
2. **Links:**
   - (a) Locally, `ruby tools/check-internal.rb` (system Nokogiri) checks that internal links and `#fragments` resolve, that every `<img>` has `alt` (decorative images use `alt=""`), and that every page links a favicon. In CI, `htmlproofer _site --disable-external --checks Links,Images,Scripts,Favicon` runs the same checks.
   - (b) `tools/check-links.sh` curls every `https://` URL in `_data/*.yml` with `-sSL -A 'Mozilla/5.0' --max-time 20`. A final status of 2xx passes. 403 and 429 are listed as warnings for a manual check. Anything else fails.
3. **Data:** `bundle exec ruby tools/check-data.rb --expect-total 14 --expect-selected 6` passes. It checks:
   - required fields are present;
   - `venue_key` and `type` are from the allowed sets;
   - every `thumb` exists, is ≤ 800px wide and ≤ 80 KB;
   - at most one `new`, and that entry has a `thumb`;
   - every link starts with `https://`;
   - `year` is non-increasing down the list;
   - `news.yml` dates match `^\d{4}(-\d{2})?$` and at most one item is `new`.

   The README tells the owner to update the `--expect-*` values when adding papers.
4. **Screenshots:** `tools/browser.mjs` (playwright-core driving the system Chrome) against `_site` served on a local port, full-page, at 1440×900 and 390×844, in `colorScheme` light and dark.
   - The 1440 light shot is compared with `mockup/D-rich.jpg`.
   - All four shots must pass `document.documentElement.scrollWidth <= innerWidth`, with no element past the right edge.
   - Emoji render (visual check, no tofu).
5. **Behavior:** `tools/browser.mjs` checks:
   - `article.pub:not([hidden])` counts 6, then 14 after clicking All;
   - news items count 7, then 12 after Show older;
   - after the theme button is clicked, `data-theme` survives a reload;
   - with JS disabled, 6 papers show and no toggle, Show older or theme button is visible.
6. **Contrast:** `tools/contrast.mjs` fails on any literal color outside the two token blocks. It checks a declared list of every (text, background) token pair the CSS uses at ≥ 4.5:1 in each theme. The translucent navbar is composited over `--ground` first.
7. **Page weight:** in Playwright Chromium at 1440×900, with a cold cache and no scrolling, the summed `transferSize` of the document and all resources 2 s after `load` is ≤ 1.2 MB.

## 10. Out of scope and follow-ups for the owner

- **COMPASS project page:** de-anonymize it (repo `LiZhYun/COMPASS`; it still shows "Anonymous Author(s)" with placeholder links). The 🌐 Project button ships pointing to it anyway.
- **CV source:** apply the five corrections from §4 to the CV LaTeX source, and mark the AgentMixer oral there.
- **Scholar numbers:** automatic updates are out of scope, because Scholar blocks bots. The numbers are updated by hand.
- **Blog:** removed. It can come back later as a separate page.
