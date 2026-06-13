// Inc 146 -- DATASET P3 lockstep gate (anon, zero spend).
// Confirms the reuse-layer schema is live + publicly readable, and enforces its
// invariants for whatever rows exist (the tables are empty at P3 schema-ship):
//   * sentences / concepts / concept_terms / audio_manifest all anon-readable
//   * sentences: valid state, live rows provenanced, non-empty variant + text
//   * concept_terms.concept_id references an existing concept; non-empty variant
//   * audio_manifest: non-empty path, valid state
const URL_ = (process.env.SUPABASE_URL || 'https://fkbmodjtxatrqcghhfba.supabase.co').replace(/\/+$/, '');
const KEY = process.env.SUPABASE_ANON_KEY || 'sb_publishable_RINvN2-MTrfUgOIZ_oxWng_aamq2i_2';
const STATES = new Set(['draft', 'live', 'deprecated']);
const H = { apikey: KEY, Authorization: `Bearer ${KEY}` };
async function getAll(p) {
  const r = await fetch(`${URL_}/rest/v1/${p}`, { headers: H });
  if (!r.ok) { console.error(`read failed ${p}: ${r.status}`); process.exit(1); }
  return r.json();
}
const problems = [];
const [sentences, concepts, terms, audio] = await Promise.all([
  getAll('sentences?select=meaning_id,lang,variant,text,state,provenance&limit=5000'),
  getAll('concepts?select=id,art_name&limit=5000'),
  getAll('concept_terms?select=concept_id,lang,variant,term&limit=5000'),
  getAll('audio_manifest?select=content_key,locale,voice,speed,path,state&limit=5000'),
]);
for (const s of sentences) {
  if (!STATES.has(s.state)) problems.push(`sentence ${s.meaning_id}/${s.lang}/${s.variant}: bad state ${s.state}`);
  if (s.state === 'live' && s.provenance == null) problems.push(`sentence ${s.meaning_id}/${s.lang}/${s.variant}: no provenance`);
  if (!s.variant) problems.push(`sentence ${s.meaning_id}/${s.lang}: empty variant`);
  if (!s.text) problems.push(`sentence ${s.meaning_id}/${s.lang}/${s.variant}: empty text`);
}
const cids = new Set(concepts.map((c) => c.id));
for (const t of terms) {
  if (!cids.has(t.concept_id)) problems.push(`concept_term '${t.term}': concept '${t.concept_id}' missing`);
  if (!t.variant) problems.push(`concept_term ${t.concept_id}/${t.lang}: empty variant`);
}
for (const a of audio) {
  if (!a.path) problems.push(`audio ${a.content_key}/${a.locale}/${a.voice}: empty path`);
  if (a.state && !STATES.has(a.state)) problems.push(`audio ${a.content_key}: bad state ${a.state}`);
}
if (problems.length) {
  console.error(`DATASET P3 LOCKSTEP FAIL (${problems.length} problems):`);
  for (const p of problems.slice(0, 15)) console.error('  ' + p);
  process.exit(1);
}
console.log(`DATASET P3 LOCKSTEP OK -- reuse layer live + anon-readable: sentences ${sentences.length}, concepts ${concepts.length}, concept_terms ${terms.length}, audio_manifest ${audio.length} (schema-valid; empty until reverse/translate/audio content lands).`);
