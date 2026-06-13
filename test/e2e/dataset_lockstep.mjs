// Inc 141 -- DATASET P0 lockstep gate (anon view, zero spend).
// Fails the build when the content dataset drifts from its P0 invariants:
//   * exercise count below the conscious FLOOR
//   * any LIVE exercise missing a grammar tag, a concept tag, or provenance
//   * any content row (unit/lesson/exercise) with an out-of-set state
//   * any LIVE tag outside the controlled vocabulary (tool/tag_taxonomy.json)
// Lifecycle law: rows are deprecated by state flip, never deleted; raise FLOOR
// consciously when units 12+ ship.
import { readFileSync } from 'node:fs';

const URL_ = (process.env.SUPABASE_URL || 'https://fkbmodjtxatrqcghhfba.supabase.co').replace(/\/+$/, '');
const KEY = process.env.SUPABASE_ANON_KEY || 'sb_publishable_RINvN2-MTrfUgOIZ_oxWng_aamq2i_2';
const FLOOR = 272;
const STATES = new Set(['draft', 'live', 'deprecated']);

const taxo = JSON.parse(readFileSync(new URL('../../tool/tag_taxonomy.json', import.meta.url)));
const GV = new Set(taxo.grammar.map((x) => x.key));
const CV = new Set(taxo.concept.map((x) => x.key));

const H = { apikey: KEY, Authorization: `Bearer ${KEY}` };
async function getAll(path) {
  const r = await fetch(`${URL_}/rest/v1/${path}`, { headers: H });
  if (!r.ok) { console.error(`read failed ${path}: ${r.status}`); process.exit(1); }
  return r.json();
}

const problems = [];
const [units, lessons, exercises] = await Promise.all([
  getAll('content_units?select=id,state,provenance&limit=2000'),
  getAll('content_lessons?select=id,state,provenance&limit=2000'),
  getAll('content_exercises?select=id,lesson_id,sort_order,state,grammar_tags,concept_tags,provenance&limit=2000'),
]);

if (exercises.length < FLOOR) problems.push(`exercise count ${exercises.length} < floor ${FLOOR}`);

for (const [tbl, rows] of [['unit', units], ['lesson', lessons], ['exercise', exercises]]) {
  for (const r of rows) {
    if (!STATES.has(r.state)) problems.push(`${tbl} ${r.id}: bad state ${JSON.stringify(r.state)}`);
    if (r.state === 'live' && r.provenance == null) problems.push(`${tbl} ${r.id}: no provenance`);
  }
}

for (const e of exercises) {
  if (e.state !== 'live') continue;
  const key = `${e.lesson_id}:${e.sort_order}`;
  const g = e.grammar_tags || [], c = e.concept_tags || [];
  if (g.length < 1) problems.push(`${key}: no grammar tag`);
  if (c.length < 1) problems.push(`${key}: no concept tag`);
  for (const t of g) if (!GV.has(t)) problems.push(`${key}: grammar tag '${t}' not in taxonomy`);
  for (const t of c) if (!CV.has(t)) problems.push(`${key}: concept tag '${t}' not in taxonomy`);
}

if (problems.length) {
  console.error(`DATASET LOCKSTEP FAIL (${problems.length} problems):`);
  for (const p of problems.slice(0, 12)) console.error('  ' + p);
  process.exit(1);
}
const liveEx = exercises.filter((e) => e.state === 'live').length;
console.log(`DATASET LOCKSTEP OK -- ${exercises.length} exercises (floor ${FLOOR}), ${liveEx} live all tagged + provenanced; vocab ${GV.size} grammar / ${CV.size} concept; states valid.`);
