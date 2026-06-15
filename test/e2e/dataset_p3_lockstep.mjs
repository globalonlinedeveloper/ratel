// Inc 146 -- DATASET P3 lockstep gate (anon, zero spend).
// Inc 182 -- EXTENDED for Phase 3.1: the reuse layer is now SEEDED for Unit 2,
// Inc 184/187 -- spine completed across the whole course (u1-u11; A1 u1-u5, A2/B1 u6-u11).
// so this gate locks that spine and enforces the license-quarantine law.
// Invariants (all anon-readable, public-read):
//   * sentences / concepts / concept_terms / audio_manifest anon-readable
//   * LICENSE-QUARANTINE LAW: every concept + every live sentence is
//     self-generated (provenance.license === 'self-generated')
//   * sentences: valid state, live rows provenanced, non-empty variant + text;
//     every concept_tags entry references an existing concept
//   * concepts: every concept has an EN (lang='en') term; concept_terms point
//     at an existing concept; non-empty variant + term
//   * SEED SPINE: the picture-backed anchors apple/bread/umbrella exist WITH a
//     non-empty art_name, and the Unit-2 sentence set (>= 10) is present
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
// Inc 197 -- PostgREST caps a single response at 1000 rows; concept_terms grew
// to 3.4k (44-locale gloss). Page with Range so the gate sees every row.
async function getAllPaged(p, pageSize = 1000) {
  const out = [];
  for (let from = 0; ; from += pageSize) {
    const r = await fetch(`${URL_}/rest/v1/${p}`, { headers: { ...H, Range: `${from}-${from + pageSize - 1}`, 'Range-Unit': 'items' } });
    if (!r.ok && r.status !== 206) { console.error(`read failed ${p}: ${r.status}`); process.exit(1); }
    const batch = await r.json();
    out.push(...batch);
    if (batch.length < pageSize) break;
  }
  return out;
}
const selfGen = (prov) => prov != null && prov.license === 'self-generated';
const problems = [];
const [sentences, concepts, terms, audio] = await Promise.all([
  getAll('sentences?select=meaning_id,lang,variant,text,state,provenance,concept_tags&limit=5000'),
  getAll('concepts?select=id,art_name,provenance&limit=5000'),
  getAllPaged('concept_terms?select=concept_id,lang,variant,term'),
  getAll('audio_manifest?select=content_key,locale,voice,speed,path,state&limit=5000'),
]);

const cids = new Set(concepts.map((c) => c.id));

// ---- concepts: license law + EN term coverage ----
const enByConcept = new Set(
  terms.filter((t) => t.lang === 'en' && t.term).map((t) => t.concept_id));
for (const c of concepts) {
  if (!selfGen(c.provenance)) problems.push(`concept ${c.id}: license not self-generated`);
  if (!enByConcept.has(c.id)) problems.push(`concept ${c.id}: no EN term`);
}

// ---- concept_terms: referential + non-empty ----
for (const t of terms) {
  if (!cids.has(t.concept_id)) problems.push(`concept_term '${t.term}': concept '${t.concept_id}' missing`);
  if (!t.variant) problems.push(`concept_term ${t.concept_id}/${t.lang}: empty variant`);
  if (!t.term) problems.push(`concept_term ${t.concept_id}/${t.lang}: empty term`);
}

// ---- Inc 197: concept-gloss coverage (44-locale Learning-language gloss) ----
// Each glossed language must name every concept (>= the EN concept count).
const GLOSS_LANGS = ['en','ta','hi','te','kn','ml','mr','gu','bn','pa','ta-Latn','es','fr','it','pt','ro','de','nl','sv','da','nb','fi','ru','uk','bg','pl','cs','sk','sl','sr','hr','lt','lv','ja','ko','zh','yue','vi','th','id','sw','tr','hu','el','et'];
const FLOOR_GLOSS = enByConcept.size; // = number of EN concepts (76)
const byLang = {};
for (const t of terms) byLang[t.lang] = (byLang[t.lang] || 0) + 1;
for (const lg of GLOSS_LANGS) {
  const n = byLang[lg] || 0;
  if (n < FLOOR_GLOSS) problems.push(`concept gloss '${lg}' ${n} < floor ${FLOOR_GLOSS}`);
}

// ---- sentences: state, license, text, and concept_tags referential ----
for (const s of sentences) {
  if (!STATES.has(s.state)) problems.push(`sentence ${s.meaning_id}/${s.lang}/${s.variant}: bad state ${s.state}`);
  if (s.state === 'live' && !selfGen(s.provenance)) problems.push(`sentence ${s.meaning_id}/${s.lang}/${s.variant}: license not self-generated`);
  if (!s.variant) problems.push(`sentence ${s.meaning_id}/${s.lang}: empty variant`);
  if (!s.text) problems.push(`sentence ${s.meaning_id}/${s.lang}/${s.variant}: empty text`);
  for (const tag of (s.concept_tags || [])) {
    if (!cids.has(tag)) problems.push(`sentence ${s.meaning_id}: concept_tag '${tag}' missing`);
  }
}

// ---- audio_manifest ----
for (const a of audio) {
  if (!a.path) problems.push(`audio ${a.content_key}/${a.locale}/${a.voice}: empty path`);
  if (a.state && !STATES.has(a.state)) problems.push(`audio ${a.content_key}: bad state ${a.state}`);
}

// ---- SEED SPINE (Inc 182-184, Phase 3.1): picture anchors + per-unit sentences ----
const artByConcept = new Map(concepts.map((c) => [c.id, c.art_name]));
for (const id of ['concept:apple', 'concept:bread', 'concept:umbrella', 'concept:spoon', 'concept:pilot', 'concept:camera', 'concept:hammer', 'concept:ticket']) {
  if (!cids.has(id)) problems.push(`seed spine: ${id} missing`);
  else if (!artByConcept.get(id)) problems.push(`seed spine: ${id} has no art_name (picture)`);
}
for (const u of ['u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8', 'u9', 'u10', 'u11']) {
  const n = sentences.filter((s) => s.meaning_id.startsWith(`sent:${u}.`)).length;
  if (n < 5) problems.push(`seed spine: expected >=5 ${u} sentences, found ${n}`);
}
if (concepts.length < 76) problems.push(`seed spine: expected >=76 concepts, found ${concepts.length}`);
const taTerms = terms.filter((t) => t.lang === 'ta' && t.term).length;
if (taTerms < 76) problems.push(`seed spine: expected >=76 Tamil terms (owner-QA'd live), found ${taTerms}`);

if (problems.length) {
  console.error(`DATASET P3 LOCKSTEP FAIL (${problems.length} problems):`);
  for (const p of problems.slice(0, 20)) console.error('  ' + p);
  process.exit(1);
}
console.log(`DATASET P3 LOCKSTEP OK (gloss ${GLOSS_LANGS.length} langs >=${FLOOR_GLOSS}) -- reuse layer seeded + self-generated: concepts ${concepts.length} (8 art anchors), concept_terms ${terms.length} (en+ta), sentences ${sentences.length} (u1-u11), audio_manifest ${audio.length}.`);
