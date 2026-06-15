// Inc 144/147 -- DATASET P1 lockstep gate (anon view, zero spend).
// app_strings is the long (key,locale,val) table -- Inc 147 contracted away the
// transitional app_strings_tr name + the P1 back-compat wide view (pre-release).
// Guards:
//   * locales en+ta enabled with CLDR plural categories
//   * app_strings ta coverage >= FLOOR; valid state; non-empty val
//   * every LIVE exercise has a unique ex: stable key + frozen legacy_key
// R1 (course_id + user_course_progress) is user-scoped (RLS) and is verified at
// migration time, not from anon REST.
const URL_ = (process.env.SUPABASE_URL || 'https://fkbmodjtxatrqcghhfba.supabase.co').replace(/\/+$/, '');
const KEY = process.env.SUPABASE_ANON_KEY || 'sb_publishable_RINvN2-MTrfUgOIZ_oxWng_aamq2i_2';
const FLOOR_TA = 311; // ta UI-string coverage; raise consciously as keys grow
const FLOOR_EX = 272; // live legacy exercises carrying stable keys
const FLOOR_ENGB = 6; // en-GB British spelling deltas (W1 Part C); deltas-only
const FLOOR_HI = 312; // hi full UI coverage (Inc 193, owner native-QA'd); raise as keys grow
const FLOOR_LTR = 50; // staged ~50-locale Chirp-3-HD LTR registry roadmap (W1 batch)
const STATES = new Set(['draft', 'live', 'deprecated']);
const H = { apikey: KEY, Authorization: `Bearer ${KEY}` };

async function getAll(path) {
  const r = await fetch(`${URL_}/rest/v1/${path}`, { headers: H });
  if (!r.ok) { console.error(`read failed ${path}: ${r.status}`); process.exit(1); }
  return r.json();
}

const problems = [];

const locales = await getAll('locales?select=code,enabled,plural_categories,fallback,direction&limit=200');
const byCode = Object.fromEntries(locales.map((l) => [l.code, l]));
for (const code of ['en', 'ta', 'hi']) {
  const l = byCode[code];
  if (!l) { problems.push(`locales: missing '${code}'`); continue; }
  if (!l.enabled) problems.push(`locales: '${code}' not enabled`);
  const pc = l.plural_categories || [];
  if (!pc.includes('one') || !pc.includes('other'))
    problems.push(`locales: '${code}' plural_categories missing one/other (${JSON.stringify(pc)})`);
}
// en-GB accent locale (W1 Part C, Inc 191): a fallback-delta locale -- enabled,
// fallback='en', carrying ONLY British spelling deltas (rest inherit en via the
// Inc-189 resolver chain). Same mechanism as any accent (en/es/fr/nl variants).
const gbLoc = byCode['en-GB'];
if (!gbLoc) {
  problems.push("locales: missing 'en-GB'");
} else {
  if (!gbLoc.enabled) problems.push("locales: 'en-GB' not enabled");
  if (gbLoc.fallback !== 'en')
    problems.push(`locales: 'en-GB' fallback '${gbLoc.fallback}' != 'en'`);
}
// Full LTR registry roadmap (W1 batch, Inc 192): the ~50-locale Chirp-3-HD LTR
// set is STAGED in `locales` (enabled only after per-language native-QA). Lock:
// the English accents are live, the roadmap count holds, NO RTL is stored, and
// every fallback target resolves to an existing row (chains never dangle).
for (const code of ['en-IN', 'en-AU']) {
  const l = byCode[code];
  if (!l) { problems.push(`locales: missing accent '${code}'`); continue; }
  if (!l.enabled) problems.push(`locales: accent '${code}' not enabled`);
  if (l.fallback !== 'en-GB')
    problems.push(`locales: '${code}' fallback '${l.fallback}' != 'en-GB'`);
}

// hi (Hindi) — first non-English BASE L1 beyond Tamil (Inc 193): enabled only
// after owner native-QA; a base locale (fallback='en', Deva script, ltr) that
// must carry FULL UI coverage (FLOOR_HI), unlike a deltas-only accent.
const hiLoc = byCode['hi'];
if (!hiLoc) {
  problems.push("locales: missing 'hi'");
} else {
  if (!hiLoc.enabled) problems.push("locales: 'hi' not enabled");
  if (hiLoc.fallback !== 'en')
    problems.push(`locales: 'hi' fallback '${hiLoc.fallback}' != 'en'`);
}
if (locales.length < FLOOR_LTR)
  problems.push(`locales registry ${locales.length} < LTR floor ${FLOOR_LTR}`);
for (const l of locales) {
  if (l.direction && l.direction !== 'ltr')
    problems.push(`locales: '${l.code}' is ${l.direction} (RTL deferred -- must not be stored yet)`);
  if (l.fallback && !byCode[l.fallback])
    problems.push(`locales: '${l.code}' fallback '${l.fallback}' has no row (dangling chain)`);
}

const rows = await getAll('app_strings?select=key,locale,val,state&limit=20000');
const keys = new Set();
let taRows = 0;
let gbRows = 0;
let hiRows = 0;
for (const r of rows) {
  keys.add(r.key);
  if (!STATES.has(r.state)) problems.push(`app_strings ${r.key}/${r.locale}: bad state ${JSON.stringify(r.state)}`);
  if (r.val == null || r.val === '') problems.push(`app_strings ${r.key}/${r.locale}: empty val`);
  if (r.locale === 'ta') taRows++;
  if (r.locale === 'en-GB') gbRows++;
  if (r.locale === 'hi') hiRows++;
}
if (taRows < FLOOR_TA) problems.push(`ta string rows ${taRows} < floor ${FLOOR_TA}`);
if (gbRows < FLOOR_ENGB) problems.push(`en-GB delta rows ${gbRows} < floor ${FLOOR_ENGB}`);
if (hiRows < FLOOR_HI) problems.push(`hi string rows ${hiRows} < floor ${FLOOR_HI}`);

const ex = await getAll('content_exercises?select=id,lesson_id,sort_order,key,legacy_key,state&limit=5000');
const live = ex.filter((e) => e.state === 'live');
if (live.length < FLOOR_EX) problems.push(`live exercises ${live.length} < floor ${FLOOR_EX}`);
const seen = new Set();
for (const e of live) {
  if (!e.key) { problems.push(`exercise ${e.id}: missing stable key`); continue; }
  if (!e.key.startsWith('ex:')) problems.push(`exercise ${e.id}: key '${e.key}' not ex:-namespaced`);
  if (seen.has(e.key)) problems.push(`exercise ${e.id}: duplicate stable key '${e.key}'`);
  seen.add(e.key);
  const want = `${e.lesson_id}:${e.sort_order}`;
  if (e.legacy_key !== want)
    problems.push(`exercise ${e.id}: legacy_key '${e.legacy_key}' != '${want}' (R6 freeze violated)`);
}

if (problems.length) {
  console.error(`APP_STRINGS/P1 LOCKSTEP FAIL (${problems.length} problems):`);
  for (const p of problems.slice(0, 15)) console.error('  ' + p);
  process.exit(1);
}
const enabledCodes = locales.filter((l) => l.enabled).map((l) => l.code).sort();
console.log(`APP_STRINGS/P1 LOCKSTEP OK -- app_strings ${keys.size} keys / ${taRows} ta rows (floor ${FLOOR_TA}) / ${gbRows} en-GB deltas (floor ${FLOOR_ENGB}) / ${hiRows} hi rows (floor ${FLOOR_HI}); ${live.length} live exercises stable-keyed + legacy-frozen (floor ${FLOOR_EX}); locales registry ${locales.length} rows (LTR floor ${FLOOR_LTR}), 0 RTL, chains resolve; enabled picker = [${enabledCodes.join(', ')}].`);
