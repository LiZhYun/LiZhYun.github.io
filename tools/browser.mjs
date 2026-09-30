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
      // Loading a lazy <img> only guarantees its bytes are fetched; with decoding="async"
      // the bitmap can still be mid-decode when a screenshot fires. Wait for every image's
      // decode to actually finish so thumbnails aren't captured blank.
      await page.evaluate(() => Promise.all(
        Array.from(document.images).map((img) => (img.decode ? img.decode().catch(() => {}) : Promise.resolve())),
      ));
      await page.waitForTimeout(300);
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
