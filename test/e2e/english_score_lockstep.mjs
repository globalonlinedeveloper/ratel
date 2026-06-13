// Inc 153 -- server-side English Score lockstep gate (anon, zero spend).
// Guards the SQL port of lib/score.dart nodeEnglishScore (Inc 151) + its
// pg_cron-refreshed cache:
//   * english_score_cache is anon-readable and non-empty
//   * every cached score in [0,100] with a band matching the 25/50/75 thresholds
//   * the live english_score(uid) RPC equals the cached value on a sample
const URL_ = (process.env.SUPABASE_URL || 'https://fkbmodjtxatrqcghhfba.supabase.co').replace(/\/+$/, '');
const KEY = process.env.SUPABASE_ANON_KEY || 'sb_publishable_RINvN2-MTrfUgOIZ_oxWng_aamq2i_2';
const H = { apikey: KEY, Authorization: `Bearer ${KEY}`, 'Content-Type': 'application/json' };
const band = (s) => (s < 25 ? 'A1' : s < 50 ? 'A2' : s < 75 ? 'B1' : 'B2');
const problems = [];

const cr = await fetch(`${URL_}/rest/v1/english_score_cache?select=user_id,score,band,nodes_assessed,computed_at&limit=5000`, { headers: H });
if (!cr.ok) { console.error(`cache read failed: ${cr.status}`); process.exit(1); }
const cache = await cr.json();
if (!Array.isArray(cache) || cache.length < 1) problems.push('english_score_cache empty (refresh/cron not populating)');

for (const r of (cache || [])) {
  if (typeof r.score !== 'number' || r.score < 0 || r.score > 100) problems.push(`score out of range: ${JSON.stringify(r.score)}`);
  if (r.band !== band(r.score)) problems.push(`band ${r.band} != ${band(r.score)} for score ${r.score}`);
  if (r.nodes_assessed == null || r.nodes_assessed < 0) problems.push(`bad nodes_assessed for ${r.user_id}`);
  if (!r.computed_at) problems.push(`no computed_at for ${r.user_id}`);
}

if (Array.isArray(cache) && cache.length) {
  for (const r of cache.slice(0, 3)) {
    const fr = await fetch(`${URL_}/rest/v1/rpc/english_score`, { method: 'POST', headers: H, body: JSON.stringify({ p_uid: r.user_id }) });
    if (!fr.ok) { problems.push(`english_score RPC failed: ${fr.status}`); continue; }
    const live = await fr.json();
    if (live !== r.score) problems.push(`RPC english_score=${live} != cached ${r.score}`);
  }
}

if (problems.length) {
  console.error(`ENGLISH-SCORE LOCKSTEP FAIL (${problems.length}):`);
  for (const p of problems.slice(0, 12)) console.error('  ' + p);
  process.exit(1);
}
console.log(`ENGLISH-SCORE LOCKSTEP OK -- ${cache.length} cached scores, all in [0,100], bands consistent; live RPC matches cache on sample.`);
