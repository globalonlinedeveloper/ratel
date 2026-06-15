// Inc 185 -- Phase 3.2: page-completeness QC report + regression gate (anon).
// Per-unit coverage of three exercise-page dimensions:
//   IMAGE -- an object-art cell exists for some content word (art_manifest vocab)
//   AUDIO -- a recorded clip exists (audio_manifest) -- device-TTS is the fallback
//   WHY   -- a pre-authored `lessonId:idx:why` key in assets/explanations.json
// Prints the per-unit + overall table and LOCKS current image coverage as a
// floor (art/concept regressions then fail CI). Real audio + pre-seeded :why
// are backfill work (owner-gated LLM/pipeline cost); both are ~0 today, so the
// report makes the gaps visible per unit for prioritisation.
import { readFileSync } from 'node:fs';

const URL_ = (process.env.SUPABASE_URL || 'https://fkbmodjtxatrqcghhfba.supabase.co').replace(/\/+$/, '');
const KEY = process.env.SUPABASE_ANON_KEY || 'sb_publishable_RINvN2-MTrfUgOIZ_oxWng_aamq2i_2';
const H = { apikey: KEY, Authorization: `Bearer ${KEY}` };
const IMAGE_FLOOR = Number(process.env.IMAGE_FLOOR || 33);
const WHY_FLOOR = Number(process.env.WHY_FLOOR || 54);

async function getAll(p) {
  const r = await fetch(`${URL_}/rest/v1/${p}`, { headers: H });
  if (!r.ok) { console.error(`read failed ${p}: ${r.status}`); process.exit(1); }
  return r.json();
}

const OBJECT_SETS = new Set(['kt', 'ho', 'tr', 'mk', 'jb', 'md']);
const STOP = new Set(['the','and','for','you','your','are','was','were','with','this','that','have','has','had','can','will','from','they','she','his','her','him','our','out','not','but','all','any','one','two','how','what','who','why','when','where','here','there','its','their','them','then','than','too','very','just','some','more','most']);
const stem = (w) => (w.length > 3 && w.endsWith('s')) ? w.slice(0, -1) : w;

const [lessons, exercises, art, audio] = await Promise.all([
  getAll('content_lessons?select=id,unit_id&limit=5000'),
  getAll('content_exercises?select=lesson_id,sort_order,type,sentence,options,correct_order&limit=5000'),
  getAll('art_manifest?select=name,path,state&limit=5000'),
  getAll('audio_manifest?select=content_key&limit=5000'),
]);

const vocab = new Set();
for (const a of art) {
  if (a.state !== 'live') continue;
  const set = (a.path || '').split('/')[0];
  if (!OBJECT_SETS.has(set)) continue;
  const us = (a.name || '').indexOf('_');
  if (us < 0) continue;
  vocab.add(stem(a.name.slice(us + 1).toLowerCase()));
}
const whyKeys = new Set(
  Object.keys(JSON.parse(readFileSync(new URL('../../assets/explanations.json', import.meta.url), 'utf8')))
    .filter((k) => k.endsWith(':why')));
const audioKeys = new Set(audio.map((a) => a.content_key));
const unitOf = new Map(lessons.map((l) => [l.id, l.unit_id]));

function contentWords(ex) {
  const fields = [];
  if (ex.sentence) fields.push(ex.sentence);
  for (const o of (ex.options || [])) fields.push(o);
  for (const c of (ex.correct_order || [])) fields.push(c);
  const out = [];
  for (const f of fields)
    for (const w of String(f).toLowerCase().split(/[^a-z]+/))
      if (w.length >= 3 && !STOP.has(w)) out.push(w);
  return out;
}

const per = new Map();
const tot = { n: 0, img: 0, aud: 0, why: 0 };
for (const ex of exercises) {
  const unit = unitOf.get(ex.lesson_id) || '?';
  const hasImg = contentWords(ex).some((w) => vocab.has(stem(w)));
  const hasWhy = whyKeys.has(`${ex.lesson_id}:${ex.sort_order}:why`);
  const hasAud = audioKeys.has(`${ex.lesson_id}:${ex.sort_order}`);
  const u = per.get(unit) || { n: 0, img: 0, aud: 0, why: 0 };
  u.n++; if (hasImg) u.img++; if (hasAud) u.aud++; if (hasWhy) u.why++;
  per.set(unit, u);
  tot.n++; if (hasImg) tot.img++; if (hasAud) tot.aud++; if (hasWhy) tot.why++;
}

const pct = (a, b) => (b ? Math.round((100 * a) / b) : 0);
const unum = (u) => Number(String(u).replace(/[^0-9]/g, '')) || 0;
console.log('PAGE-COMPLETENESS QC (per unit -- image / audio / why):');
for (const u of [...per.keys()].sort((a, b) => unum(a) - unum(b))) {
  const x = per.get(u);
  console.log(`  ${u.padEnd(4)} n=${String(x.n).padStart(3)}  img ${String(x.img).padStart(3)} (${String(pct(x.img, x.n)).padStart(3)}%)  aud ${x.aud} (${pct(x.aud, x.n)}%)  why ${x.why} (${pct(x.why, x.n)}%)`);
}
console.log(`  TOT  n=${String(tot.n).padStart(3)}  img ${tot.img} (${pct(tot.img, tot.n)}%)  aud ${tot.aud} (${pct(tot.aud, tot.n)}%)  why ${tot.why} (${pct(tot.why, tot.n)}%)`);

if (tot.img < IMAGE_FLOOR) {
  console.error(`PAGE-COMPLETENESS FAIL: image-covered ${tot.img} < floor ${IMAGE_FLOOR}`);
  process.exit(1);
}
if (tot.why < WHY_FLOOR) {
  console.error(`PAGE-COMPLETENESS FAIL: why-covered ${tot.why} < floor ${WHY_FLOOR}`);
  process.exit(1);
}
console.log(`PAGE-COMPLETENESS OK -- image floor ${IMAGE_FLOOR} held (img ${tot.img}/${tot.n}); why floor ${WHY_FLOOR} held (why ${tot.why}/${tot.n}); audio backfill pending.`);
