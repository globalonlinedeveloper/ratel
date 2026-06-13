// Inc 145 -- DATASET P2 lockstep gate (anon view, zero spend).
// Guards the curriculum-skeleton schema layer:
//   * tags table is a SUPERSET of tool/tag_taxonomy.json (per kind)
//   * course_family contains 'gen'
//   * every curriculum_node: valid state, live rows provenanced, grammar_focus
//     & topic within the tag vocab, prereqs reference existing nodes + ACYCLIC
//   * every content_lessons.node_id (when set) references an existing node
// Node population is owner-gated (granularity lock) so the table may be empty;
// the gate still enforces the schema invariants for whatever IS present.
import { readFileSync } from 'node:fs';

const URL_ = (process.env.SUPABASE_URL || 'https://fkbmodjtxatrqcghhfba.supabase.co').replace(/\/+$/, '');
const KEY = process.env.SUPABASE_ANON_KEY || 'sb_publishable_RINvN2-MTrfUgOIZ_oxWng_aamq2i_2';
const STATES = new Set(['draft', 'live', 'deprecated']);
const FLOOR_NODES = 29; // Skill-tier curriculum nodes (Inc 148); raise as curriculum grows
const FLOOR_MAPPED = 54; // every live lesson maps to a node
const taxo = JSON.parse(readFileSync(new URL('../../tool/tag_taxonomy.json', import.meta.url)));
const GV = new Set(taxo.grammar.map((x) => x.key));
const CV = new Set(taxo.concept.map((x) => x.key));
const H = { apikey: KEY, Authorization: `Bearer ${KEY}` };
async function getAll(p) {
  const r = await fetch(`${URL_}/rest/v1/${p}`, { headers: H });
  if (!r.ok) { console.error(`read failed ${p}: ${r.status}`); process.exit(1); }
  return r.json();
}

const problems = [];
const [tags, fam, nodes, lessons] = await Promise.all([
  getAll('tags?select=key,kind,state&limit=5000'),
  getAll('course_family?select=id,state&limit=200'),
  getAll('curriculum_nodes?select=id,family,cefr,topic,grammar_focus,prereq_ids,state,provenance&limit=5000'),
  getAll('content_lessons?select=id,node_id&limit=5000'),
]);

const tg = new Set(tags.filter((t) => t.kind === 'grammar').map((t) => t.key));
const tc = new Set(tags.filter((t) => t.kind === 'concept').map((t) => t.key));
for (const k of GV) if (!tg.has(k)) problems.push(`tags missing grammar '${k}'`);
for (const k of CV) if (!tc.has(k)) problems.push(`tags missing concept '${k}'`);
for (const t of tags) {
  if (t.kind !== 'grammar' && t.kind !== 'concept') problems.push(`tag ${t.key}: bad kind ${t.kind}`);
  if (!STATES.has(t.state)) problems.push(`tag ${t.key}: bad state ${t.state}`);
}

if (!fam.some((f) => f.id === 'gen')) problems.push("course_family missing 'gen'");

const nodeIds = new Set(nodes.map((n) => n.id));
for (const n of nodes) {
  if (!STATES.has(n.state)) problems.push(`node ${n.id}: bad state ${n.state}`);
  if (n.state === 'live' && n.provenance == null) problems.push(`node ${n.id}: no provenance`);
  for (const g of n.grammar_focus || []) if (!tg.has(g)) problems.push(`node ${n.id}: grammar_focus '${g}' not a tag`);
  if (n.topic && !tc.has(n.topic)) problems.push(`node ${n.id}: topic '${n.topic}' not a concept tag`);
  for (const p of n.prereq_ids || []) if (!nodeIds.has(p)) problems.push(`node ${n.id}: prereq '${p}' missing`);
}
// acyclic prereqs (DFS three-colour)
const adj = new Map(nodes.map((n) => [n.id, (n.prereq_ids || []).filter((p) => nodeIds.has(p))]));
const color = new Map([...nodeIds].map((id) => [id, 0]));
let cycle = null;
function dfs(u) {
  color.set(u, 1);
  for (const v of adj.get(u) || []) {
    if (color.get(v) === 1) { cycle = `${u}->${v}`; return true; }
    if (color.get(v) === 0 && dfs(v)) return true;
  }
  color.set(u, 2);
  return false;
}
for (const id of nodeIds) { if (color.get(id) === 0 && dfs(id)) break; }
if (cycle) problems.push(`curriculum_nodes prereq cycle at ${cycle}`);

for (const l of lessons) if (l.node_id && !nodeIds.has(l.node_id)) problems.push(`lesson ${l.id}: node_id '${l.node_id}' missing`);
if (nodes.length < FLOOR_NODES) problems.push(`curriculum_nodes ${nodes.length} < floor ${FLOOR_NODES}`);
const mappedCount = lessons.filter((l) => l.node_id).length;
if (mappedCount < FLOOR_MAPPED) problems.push(`live lessons node-mapped ${mappedCount} < ${FLOOR_MAPPED}`);

if (problems.length) {
  console.error(`DATASET P2 LOCKSTEP FAIL (${problems.length} problems):`);
  for (const p of problems.slice(0, 15)) console.error('  ' + p);
  process.exit(1);
}
const mapped = lessons.filter((l) => l.node_id).length;
console.log(`DATASET P2 LOCKSTEP OK -- tags ${tags.length} (>= ${GV.size}+${CV.size} taxonomy); course_family ${fam.length} (gen); curriculum_nodes ${nodes.length} (schema valid + acyclic); ${mapped}/${lessons.length} lessons node-mapped.`);
