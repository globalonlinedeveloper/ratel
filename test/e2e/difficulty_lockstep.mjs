// Inc 186 -- Phase 3.4 difficulty lockstep (anon, zero spend).
// Asserts every LIVE exercise carries a difficulty PRIOR in (0,1], and the
// public calibration RPC (exercise_calibration -- a SECURITY DEFINER aggregate
// over the RLS-protected attempts table, exposing only per-exercise counts) is
// anon-readable and structurally sane. attempts COUNT is reported, not gated
// (it is user-data dependent and may shrink on account cleanup).
const URL_ = (process.env.SUPABASE_URL || 'https://fkbmodjtxatrqcghhfba.supabase.co').replace(/\/+$/, '');
const KEY = process.env.SUPABASE_ANON_KEY || 'sb_publishable_RINvN2-MTrfUgOIZ_oxWng_aamq2i_2';
const H = { apikey: KEY, Authorization: `Bearer ${KEY}` };

async function getJson(p, opts = {}) {
  const r = await fetch(`${URL_}/rest/v1/${p}`, { headers: H, ...opts });
  if (!r.ok) { console.error(`read failed ${p}: ${r.status} ${await r.text()}`); process.exit(1); }
  return r.json();
}

const problems = [];
const ex = await getJson('content_exercises?select=id,state,difficulty&limit=5000');
let live = 0, liveNull = 0, outOfRange = 0;
for (const e of ex) {
  if (e.state !== 'live') continue;
  live++;
  if (e.difficulty == null) liveNull++;
  else if (e.difficulty <= 0 || e.difficulty > 1) outOfRange++;
}
if (live === 0) problems.push('no live exercises');
if (liveNull) problems.push(`${liveNull} live exercises have NULL difficulty (priors missing)`);
if (outOfRange) problems.push(`${outOfRange} exercises have difficulty outside (0,1]`);

const calib = await getJson('rpc/exercise_calibration', {
  method: 'POST', headers: { ...H, 'Content-Type': 'application/json' }, body: '{}',
});
if (!Array.isArray(calib) || calib.length === 0) problems.push('calibration RPC returned no rows');
let totAtt = 0, withAtt = 0, nullPrior = 0, badP = 0;
for (const c of (Array.isArray(calib) ? calib : [])) {
  const a = Number(c.attempts) || 0; totAtt += a; if (a > 0) withAtt++;
  if (c.prior == null) nullPrior++;
  if (c.p_wrong != null && (Number(c.p_wrong) < 0 || Number(c.p_wrong) > 1)) badP++;
}
if (Array.isArray(calib) && calib.length < live) problems.push(`calibration covers ${calib.length} < ${live} live exercises`);
if (nullPrior) problems.push(`${nullPrior} calibration rows missing a prior`);
if (badP) problems.push(`${badP} calibration rows have p_wrong outside [0,1]`);

if (problems.length) {
  console.error(`DIFFICULTY LOCKSTEP FAIL (${problems.length}):`);
  for (const p of problems) console.error('  ' + p);
  process.exit(1);
}
console.log(`DIFFICULTY LOCKSTEP OK -- ${live} live exercises priored in (0,1]; calibration ${calib.length} rows, ${withAtt} with attempts (${totAtt} total).`);
