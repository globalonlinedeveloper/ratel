// Inc 140 — art_manifest <-> storage lockstep gate (anon view, zero spend).
// Fails the build when a manifest row's public object is missing/mis-sized,
// when names/paths collide, or when the catalog shrinks below the Inc 140
// baseline (raise FLOOR consciously when new sets ship).
const URL_ = (process.env.SUPABASE_URL || 'https://fkbmodjtxatrqcghhfba.supabase.co').replace(/\/+$/, '');
const KEY = process.env.SUPABASE_ANON_KEY || 'sb_publishable_RINvN2-MTrfUgOIZ_oxWng_aamq2i_2';
const FLOOR = 204;

const problems = [];
const res = await fetch(`${URL_}/rest/v1/art_manifest?select=name,set,path,bytes&limit=2000`, {
  headers: { apikey: KEY, Authorization: `Bearer ${KEY}` },
});
if (!res.ok) { console.error(`manifest read failed: ${res.status}`); process.exit(1); }
const rows = await res.json();

if (rows.length < FLOOR) problems.push(`manifest count ${rows.length} < floor ${FLOOR}`);
const names = new Set(), paths = new Set();
for (const r of rows) {
  if (names.has(r.name)) problems.push(`duplicate name: ${r.name}`);
  if (paths.has(r.path)) problems.push(`duplicate path: ${r.path}`);
  names.add(r.name); paths.add(r.path);
  if (!/^[a-z0-9-]+\/[A-Za-z0-9._-]+\.webp$/.test(r.path)) problems.push(`odd path: ${r.path}`);
  if (!(r.bytes > 0)) problems.push(`zero-byte row: ${r.name}`);
}

let probed = 0;
const queue = [...rows];
async function worker() {
  for (;;) {
    const r = queue.shift();
    if (!r) return;
    try {
      const h = await fetch(`${URL_}/storage/v1/object/public/art/${r.path}`, { method: 'HEAD' });
      if (h.status !== 200) { problems.push(`${r.path}: HTTP ${h.status}`); continue; }
      const len = h.headers.get('content-length');
      if (len !== null && Number(len) !== r.bytes) problems.push(`${r.path}: bytes ${r.bytes} != content-length ${len}`);
      probed++;
    } catch (e) { problems.push(`${r.path}: ${e.message}`); }
  }
}
await Promise.all(Array.from({ length: 12 }, worker));

if (problems.length) {
  console.error(`ART LOCKSTEP FAIL (${problems.length} problems):`);
  for (const p of problems.slice(0, 10)) console.error('  ' + p);
  process.exit(1);
}
console.log(`ART LOCKSTEP OK — ${rows.length} manifest rows, ${probed} storage objects probed 200, sets: ${new Set(rows.map(r => r.set)).size}`);
