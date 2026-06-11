// Weekly LIVE-SITE tour: production reachability + render + data.
// Non-destructive by design: no sign-ups, no writes, anon key only.
import { chromium } from 'playwright';

const LIVE = 'https://globalonlinedeveloper.github.io/ratel/';
const URL_ = process.env.SUPABASE_URL;
const KEY = process.env.SUPABASE_ANON_KEY;
const fails = [];
const ok = (name, cond, extra = '') => {
  console.log(`${cond ? 'OK ' : 'FAIL'} ${name}${extra ? ' — ' + extra : ''}`);
  if (!cond) fails.push(name);
};

// 1. commit marker: reachable, well-formed
const sha = (await (await fetch(`${LIVE}commit.txt?cb=${Date.now()}`)).text()).trim();
ok('commit marker', /^[0-9a-f]{40}$/.test(sha), sha.slice(0, 7));

// 2. anon data endpoints serve real rows
const rest = async (path) => {
  const r = await fetch(`${URL_}/rest/v1/${path}`, {
    headers: { apikey: KEY, Authorization: `Bearer ${KEY}` },
  });
  return r.ok ? r.json() : null;
};
const units = await rest('content_units?select=id');
ok('content_units', Array.isArray(units) && units.length >= 10,
   `${units?.length ?? 'none'} units`);
const flags = await rest('app_flags?select=key');
ok('app_flags', Array.isArray(flags) && flags.length >= 5);
const strings = await rest('app_strings?select=key');
ok('app_strings', Array.isArray(strings) && strings.length >= 1);

// 3. the shell actually renders for a visitor
const browser = await chromium.launch();
const page = await browser.newContext(
    { viewport: { width: 412, height: 915 } }).then((c) => c.newPage());
const errors = [];
page.on('pageerror', (e) => errors.push(String(e).slice(0, 120)));
await page.goto(`${LIVE}?cb=${Date.now()}`);
await page.waitForTimeout(9000);
for (let i = 0; i < 12; i++) {
  await page.evaluate(() =>
    document.querySelector('flt-semantics-placeholder')?.click());
  await page.waitForTimeout(700);
  if (await page.locator(
      'flt-semantics-host [aria-label], flt-semantics-host span')
      .count() > 3) break;
}
const guest = await page.getByText('Just let me try it').count();
const semNodes = await page.locator(
    'flt-semantics-host [aria-label], flt-semantics-host span').count();
ok('app shell renders', semNodes > 3, `${semNodes} semantic nodes`);
ok('guest entry visible', guest > 0);
ok('no page errors', errors.length === 0, errors.join(' | '));
await page.screenshot({ path: 'live-tour.png' });
await browser.close();

if (fails.length) {
  console.error('LIVE TOUR FAIL:', fails.join(', '));
  process.exit(1);
}
console.log('live tour green');
