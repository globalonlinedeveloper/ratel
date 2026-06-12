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

// 4. TAMIL LEG: locale=ta end-to-end — guest entry, home + profile,
// full-page scroll with screenshots (reviewed by a human/Claude after).
try {
  const ctx = await browser.newContext(
      { viewport: { width: 412, height: 915 } });
  await ctx.addInitScript(() =>
    localStorage.setItem('flutter.app_locale', '"ta"'));
  const ta = await ctx.newPage();
  const taErrors = [];
  ta.on('pageerror', (e) => taErrors.push(String(e).slice(0, 120)));
  await ta.goto(`${LIVE}?cb=ta${Date.now()}`);
  await ta.waitForTimeout(9000);
  for (let i = 0; i < 12; i++) {
    await ta.evaluate(() =>
      document.querySelector('flt-semantics-placeholder')?.click());
    await ta.waitForTimeout(700);
    if (await ta.locator(
        'flt-semantics-host [aria-label], flt-semantics-host span')
        .count() > 3) break;
  }
  await ta.screenshot({ path: 'ta-auth.png' });
  // guest entry — Tamil label first, English fallback
  const guestTa = ta.getByText('முதலில் முயற்சித்துப் பார்க்கிறேன்');
  const guestEn = ta.getByText('Just let me try it');
  if (await guestTa.count()) await guestTa.first().click();
  else if (await guestEn.count()) await guestEn.first().click();
  await ta.waitForTimeout(4000);
  // guest entry lands on onboarding — finish it to reach home
  const start = ta.getByText('Start learning');
  if (await start.count()) {
    await start.first().click();
    await ta.waitForTimeout(5000);
  }
  await ta.screenshot({ path: 'ta-home-1.png' });
  for (let i = 0; i < 3; i++) {
    await ta.mouse.wheel(0, 1400);
    await ta.waitForTimeout(800);
    await ta.screenshot({ path: `ta-home-${i + 2}.png` });
  }
  // FULL-FLOW (Inc 129d): start a lesson by the Tamil pill, skip once to
  // surface the wrong-answer banner, tap Explain (server ta path), then
  // tour Practice/Coach/Leagues tabs. Tamil label first, EN fallback.
  const byTa = async (taTxt, enTxt) => {
    const t = ta.getByText(taTxt);
    if (await t.count()) return t.first();
    const e = ta.getByText(enTxt);
    return (await e.count()) ? e.first() : null;
  };
  const startPill = await byTa('தொடங்கு', 'Start');
  if (startPill) {
    await startPill.click();
    await ta.waitForTimeout(4500);
    await ta.screenshot({ path: 'ta-lesson-1.png' });
    const skip = await byTa('தவிர்', 'Skip');
    if (skip) {
      await skip.click();
      await ta.waitForTimeout(2500);
      await ta.screenshot({ path: 'ta-lesson-2-banner.png' });
      const expl = await byTa('விளக்கு', 'Explain this');
      if (expl) {
        await expl.click();
        await ta.waitForTimeout(8000); // server generate can take a beat
        await ta.screenshot({ path: 'ta-lesson-3-explain.png' });
      }
      // leave the lesson via the quit dialog (X then confirm) — best-effort
      const x = ta.locator('flt-semantics-host [aria-label="Close"]');
      if (await x.count()) {
        await x.first().click();
        await ta.waitForTimeout(1500);
        const leave = await byTa('வெளியேறு', 'Leave');
        if (leave) await leave.click();
        await ta.waitForTimeout(3000);
      }
    }
  }
  for (const [taL, enL, shot] of [
    ['பயிற்சி', 'Practice', 'ta-practice.png'],
    ['கோச்', 'Coach', 'ta-coach.png'],
    ['லீக்', 'Leagues', 'ta-leagues.png'],
  ]) {
    const tab = await byTa(taL, enL);
    if (tab) {
      await tab.click();
      await ta.waitForTimeout(3000);
      await ta.screenshot({ path: shot });
    }
  }
  const prof = await byTa('சுயவிவரம்', 'Profile') ??
      ta.getByText('Profile');
  if (prof && await prof.count()) {
    await prof.click();
    await ta.waitForTimeout(2500);
    await ta.screenshot({ path: 'ta-profile-1.png' });
    for (let i = 0; i < 2; i++) {
      await ta.mouse.wheel(0, 1400);
      await ta.waitForTimeout(800);
      await ta.screenshot({ path: `ta-profile-${i + 2}.png` });
    }
  }

  ok('tamil leg: no page errors', taErrors.length === 0,
     taErrors.join(' | '));
  await ctx.close();
} catch (e) {
  ok('tamil leg ran', false, String(e).slice(0, 140));
}
await browser.close();

if (fails.length) {
  console.error('LIVE TOUR FAIL:', fails.join(', '));
  process.exit(1);
}
console.log('live tour green');
