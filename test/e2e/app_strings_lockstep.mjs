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
const FLOOR_BETA = 312; // Inc 195: every beta machine-translated L1 locale must carry full UI coverage
// Inc 195 — 41 base L1 + ta-Latn romanization: machine-translated (Sonnet draft + Opus-4.8 review),
// shipped enabled with locales.tier='beta' (provenance native_qa='none'); owner native-QA deferred.
const BETA_FULL = ['bg','bn','cs','da','de','el','es','et','fi','fr','gu','hr','hu','id','it','ja','kn','ko','lt','lv','ml','mr','nb','nl','pa','pl','pt','ro','ru','sk','sl','sr','sv','sw','te','th','tr','uk','vi','yue','zh','ta-Latn'];
// accent variants: enabled, deltas-only (es-US->es, fr-CA->fr, nl-BE->nl), inherit base via fallback.
const BETA_VARIANT = ['es-US','fr-CA','nl-BE'];
const STATES = new Set(['draft', 'live', 'deprecated']);
const H = { apikey: KEY, Authorization: `Bearer ${KEY}` };

async function getAll(path) {
  const r = await fetch(`${URL_}/rest/v1/${path}`, { headers: H });
  if (!r.ok) { console.error(`read failed ${path}: ${r.status}`); process.exit(1); }
  return r.json();
}

// Paginated fetch: PostgREST caps a single response at max-rows (1000). app_strings
// grew past that at Inc 195 (13.9k rows), so page through with Range until exhausted.
async function getAllPaged(path, pageSize = 1000) {
  const out = [];
  for (let from = 0; ; from += pageSize) {
    const to = from + pageSize - 1;
    const r = await fetch(`${URL_}/rest/v1/${path}`, { headers: { ...H, Range: `${from}-${to}`, 'Range-Unit': 'items' } });
    if (!r.ok && r.status !== 206) { console.error(`read failed ${path}: ${r.status}`); process.exit(1); }
    const batch = await r.json();
    out.push(...batch);
    if (batch.length < pageSize) break;
  }
  return out;
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

// Inc 195 — beta locale registry checks: each newly-enabled locale must be enabled,
// declare CLDR plural categories (every language has 'other'), and (full L1) carry coverage.
for (const code of [...BETA_FULL, ...BETA_VARIANT]) {
  const l = byCode[code];
  if (!l) { problems.push(`locales: missing beta '${code}'`); continue; }
  if (!l.enabled) problems.push(`locales: beta '${code}' not enabled`);
  const pc = l.plural_categories || [];
  if (!pc.includes('other')) problems.push(`locales: beta '${code}' plural_categories missing 'other' (${JSON.stringify(pc)})`);
}
if (locales.length < FLOOR_LTR)
  problems.push(`locales registry ${locales.length} < LTR floor ${FLOOR_LTR}`);
for (const l of locales) {
  if (l.direction && l.direction !== 'ltr')
    problems.push(`locales: '${l.code}' is ${l.direction} (RTL deferred -- must not be stored yet)`);
  if (l.fallback && !byCode[l.fallback])
    problems.push(`locales: '${l.code}' fallback '${l.fallback}' has no row (dangling chain)`);
}

const rows = await getAllPaged('app_strings?select=key,locale,val,state');
const keys = new Set();
let taRows = 0;
let gbRows = 0;
let hiRows = 0;
const rowCount = {};
for (const r of rows) {
  keys.add(r.key);
  if (!STATES.has(r.state)) problems.push(`app_strings ${r.key}/${r.locale}: bad state ${JSON.stringify(r.state)}`);
  if (r.val == null || r.val === '') problems.push(`app_strings ${r.key}/${r.locale}: empty val`);
  if (r.locale === 'ta') taRows++;
  if (r.locale === 'en-GB') gbRows++;
  if (r.locale === 'hi') hiRows++;
  rowCount[r.locale] = (rowCount[r.locale] || 0) + 1;
}
if (taRows < FLOOR_TA) problems.push(`ta string rows ${taRows} < floor ${FLOOR_TA}`);
if (gbRows < FLOOR_ENGB) problems.push(`en-GB delta rows ${gbRows} < floor ${FLOOR_ENGB}`);
if (hiRows < FLOOR_HI) problems.push(`hi string rows ${hiRows} < floor ${FLOOR_HI}`);
// Inc 195 — every full beta L1 locale must carry >= FLOOR_BETA rows (deltas-only variants exempt;
// they inherit their base through the resolver fallback chain).
for (const code of BETA_FULL) {
  const n = rowCount[code] || 0;
  if (n < FLOOR_BETA) problems.push(`beta '${code}' string rows ${n} < floor ${FLOOR_BETA}`);
}

const ex = await getAllPaged('content_exercises?select=id,lesson_id,sort_order,key,legacy_key,state');
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
const betaFull = BETA_FULL.filter((c) => (rowCount[c] || 0) >= FLOOR_BETA).length;
console.log(`APP_STRINGS/P1 LOCKSTEP OK -- app_strings ${keys.size} keys / ${taRows} ta rows (floor ${FLOOR_TA}) / ${gbRows} en-GB deltas (floor ${FLOOR_ENGB}) / ${hiRows} hi rows (floor ${FLOOR_HI}) / ${betaFull}/${BETA_FULL.length} beta L1 locales >=${FLOOR_BETA} + ${BETA_VARIANT.length} variants (Inc 195); ${live.length} live exercises stable-keyed + legacy-frozen (floor ${FLOOR_EX}); locales registry ${locales.length} rows (LTR floor ${FLOOR_LTR}), 0 RTL, chains resolve; enabled picker = [${enabledCodes.join(', ')}].`);
