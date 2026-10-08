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
  ...['neurips', 'icml', 'aaai', 'arxiv', 'nn', 'tnsm', 'tpami', 'eaai', 'apin', 'aamas', 'bmvc', 'ijcnn'].map((v) => ['--on-badge', `--v-${v}`]),
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
