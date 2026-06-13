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
const STATES = new Set(['draft', 'live', 'deprecated']);
const H = { apikey: KEY, Authorization: `Bearer ${KEY}` };

async function getAll(path) {
  const r = await fetch(`${URL_}/rest/v1/${path}`, { headers: H });
  if (!r.ok) { console.error(`read failed ${path}: ${r.status}`); process.exit(1); }
  return r.json();
}

const problems = [];

const locales = await getAll('locales?select=code,enabled,plural_categories&limit=200');
const byCode = Object.fromEntries(locales.map((l) => [l.code, l]));
for (const code of ['en', 'ta']) {
  const l = byCode[code];
  if (!l) { problems.push(`locales: missing '${code}'`); continue; }
  if (!l.enabled) problems.push(`locales: '${code}' not enabled`);
  const pc = l.plural_categories || [];
  if (!pc.includes('one') || !pc.includes('other'))
    problems.push(`locales: '${code}' plural_categories missing one/other (${JSON.stringify(pc)})`);
}

const rows = await getAll('app_strings?select=key,locale,val,state&limit=20000');
const keys = new Set();
let taRows = 0;
for (const r of rows) {
  keys.add(r.key);
  if (!STATES.has(r.state)) problems.push(`app_strings ${r.key}/${r.locale}: bad state ${JSON.stringify(r.state)}`);
  if (r.val == null || r.val === '') problems.push(`app_strings ${r.key}/${r.locale}: empty val`);
  if (r.locale === 'ta') taRows++;
}
if (taRows < FLOOR_TA) problems.push(`ta string rows ${taRows} < floor ${FLOOR_TA}`);

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
console.log(`APP_STRINGS/P1 LOCKSTEP OK -- app_strings ${keys.size} keys / ${taRows} ta rows (floor ${FLOOR_TA}); ${live.length} live exercises stable-keyed + legacy-frozen (floor ${FLOOR_EX}); locales en+ta enabled w/ CLDR plural categories.`);
