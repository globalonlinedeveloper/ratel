// Inc 153 (gate hardened Inc 155b) -- server English Score lockstep (anon, zero spend).
// Verifies the SQL port of lib/score.dart nodeEnglishScore + its pg_cron cache by
// INVARIANTS (the cache is eventually-consistent, so we never require cache==live):
//   * english_score_cache anon-readable + non-empty; every score in [0,100] with a
//     band matching the 25/50/75 thresholds; computed_at present.
//   * the live english_score(uid) RPC returns valid [0,100] + consistent band for a sample.
//   * deterministic: english_score(<all-zero uuid, no attempts>) == 0 (breadth pressure).
const URL_ = (process.env.SUPABASE_URL || 'https://fkbmodjtxatrqcghhfba.supabase.co').replace(/\/+$/, '');
const KEY = process.env.SUPABASE_ANON_KEY || 'sb_publishable_RINvN2-MTrfUgOIZ_oxWng_aamq2i_2';
const H = { apikey: KEY, Authorization: `Bearer ${KEY}`, 'Content-Type': 'application/json' };
const band = (s) => (s < 25 ? 'A1' : s < 50 ? 'A2' : s < 75 ? 'B1' : 'B2');
const problems = [];
const rpc = async (uid) => {
  const r = await fetch(`${URL_}/rest/v1/rpc/english_score`, { method: 'POST', headers: H, body: JSON.stringify({ p_uid: uid }) });
  if (!r.ok) { problems.push(`english_score RPC failed: ${r.status}`); return null; }
  return r.json();
};

const cr = await fetch(`${URL_}/rest/v1/english_score_cache?select=user_id,score,band,nodes_assessed,computed_at&limit=5000`, { headers: H });
if (!cr.ok) { console.error(`cache read failed: ${cr.status}`); process.exit(1); }
const cache = await cr.json();
if (!Array.isArray(cache) || cache.length < 1) problems.push('english_score_cache empty (refresh/cron not populating)');
for (const r of (cache || [])) {
  if (typeof r.score !== 'number' || r.score < 0 || r.score > 100) problems.push(`cache score out of range: ${JSON.stringify(r.score)}`);
  if (r.band !== band(r.score)) problems.push(`cache band ${r.band} != ${band(r.score)} for ${r.score}`);
  if (r.nodes_assessed == null || r.nodes_assessed < 0) problems.push(`bad nodes_assessed for ${r.user_id}`);
  if (!r.computed_at) problems.push(`no computed_at for ${r.user_id}`);
}
// live function validity on a sample (NOT compared to cache -- cache lags by design)
for (const r of (Array.isArray(cache) ? cache.slice(0, 3) : [])) {
  const live = await rpc(r.user_id);
  if (live !== null && (typeof live !== 'number' || live < 0 || live > 100)) problems.push(`RPC english_score=${live} out of [0,100]`);
}
// deterministic: a uid with no attempts scores 0 (all nodes un-attempted)
const zero = await rpc('00000000-0000-0000-0000-000000000000');
if (zero !== null && zero !== 0) problems.push(`english_score(no-attempts uuid) = ${zero}, expected 0`);

if (problems.length) {
  console.error(`ENGLISH-SCORE LOCKSTEP FAIL (${problems.length}):`);
  for (const p of problems.slice(0, 12)) console.error('  ' + p);
  process.exit(1);
}
console.log(`ENGLISH-SCORE LOCKSTEP OK -- ${cache.length} cached scores valid (range+band+computed_at); live RPC valid on sample; no-attempts uuid scores 0.`);
