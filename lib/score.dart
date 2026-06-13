// Node-based English Score (Inc 151 — adoption of the curriculum_nodes spine,
// docs/Ratel-English-Score-Node-Adoption-Spec.md). Pure + unit-testable: turns
// a learner's raw attempts into per-skill (curriculum node) mastery and rolls
// that up into a CEFR-band-weighted 0-100 score. No Flutter, no I/O — so it is
// trivially testable and reusable (placement, weak-areas, later the composer).

/// CEFR band weights: higher skills are worth more (spec §3, owner default
/// 1/2/3). B2 carries the linear step forward for any future B2 nodes.
const Map<String, int> kBandWeights = {'A1': 1, 'A2': 2, 'B1': 3, 'B2': 4};

/// Attempts on a node's exercises before it counts as *assessed* (spec §7 #2,
/// owner default 3). Below this, a node's mastery reads 0 (not yet shown).
const int kMinAttempts = 3;

/// An assessed node below this correct-rate is a "weak area" (spec §7 #5).
const double kWeakThreshold = 0.60;

/// The lesson id embedded in an attempt's exercise_key ("u1l4:0" -> "u1l4").
String lessonOfKey(String exerciseKey) {
  final i = exerciseKey.indexOf(':');
  return i < 0 ? exerciseKey : exerciseKey.substring(0, i);
}

/// Raw correct/total tally per node over EVERY attempt row (repeat attempts all
/// count — v1 correct-rate, spec §3). Attempts whose lesson maps to no node
/// (smart-practice / review keys, or offline before content loads) are skipped.
Map<String, ({int correct, int total})> nodeTallies(
  Iterable<({String key, bool correct})> attempts,
  Map<String, String> lessonNode,
) {
  final out = <String, ({int correct, int total})>{};
  for (final a in attempts) {
    final node = lessonNode[lessonOfKey(a.key)];
    if (node == null) continue;
    final prev = out[node] ?? (correct: 0, total: 0);
    out[node] = (
      correct: prev.correct + (a.correct ? 1 : 0),
      total: prev.total + 1,
    );
  }
  return out;
}

/// Mastery in [0,1] for one tally: correct-rate once at least [minAttempts]
/// attempts exist, else 0 — an under-sampled node is unknown, not zero-skill.
double masteryOf(int correct, int total, {int minAttempts = kMinAttempts}) {
  if (total < minAttempts || total <= 0) return 0.0;
  final m = correct / total;
  return m < 0 ? 0.0 : (m > 1 ? 1.0 : m);
}

/// Per-node gated mastery for the attempted nodes. Un-attempted nodes are
/// absent; the aggregate treats a missing node as 0 so breadth still counts.
Map<String, double> nodeMastery(
  Iterable<({String key, bool correct})> attempts,
  Map<String, String> lessonNode, {
  int minAttempts = kMinAttempts,
}) {
  final tallies = nodeTallies(attempts, lessonNode);
  return tallies.map((node, t) =>
      MapEntry(node, masteryOf(t.correct, t.total, minAttempts: minAttempts)));
}

/// Band-weighted 0-100 score over the FULL node set [nodeBands] (node -> CEFR).
/// Un-attempted / zero-mastery nodes pull the weighted average down, so the
/// score rewards breadth AND depth (spec §3). 0 when there are no nodes.
int nodeEnglishScore(
  Map<String, double> mastery,
  Map<String, String> nodeBands, {
  Map<String, int> bandWeights = kBandWeights,
}) {
  double acc = 0, den = 0;
  for (final entry in nodeBands.entries) {
    final w = (bandWeights[entry.value] ?? 1).toDouble();
    den += w;
    acc += w * (mastery[entry.key] ?? 0.0);
  }
  if (den <= 0) return 0;
  final s = (100 * acc / den).round();
  return s < 0 ? 0 : (s > 100 ? 100 : s);
}

/// Assessed nodes below [threshold], worst-first — drives weak-area practice
/// (spec §3). Only nodes with >= [minAttempts] attempts qualify (an unassessed
/// node is unknown, not weak).
List<String> weakNodes(
  Map<String, ({int correct, int total})> tallies, {
  int minAttempts = kMinAttempts,
  double threshold = kWeakThreshold,
}) {
  final weak = <({String node, double m})>[];
  for (final e in tallies.entries) {
    if (e.value.total < minAttempts) continue;
    final m = e.value.correct / e.value.total;
    if (m < threshold) weak.add((node: e.key, m: m));
  }
  weak.sort((a, b) => a.m.compareTo(b.m));
  return [for (final w in weak) w.node];
}

/// Human-readable label for a node id ("node:gen.a1.past-simple" ->
/// "Past simple") — pure display helper for weak-area rows.
String nodeLabel(String nodeId) {
  final seg = nodeId.split('.').last;
  if (seg.isEmpty) return nodeId;
  return seg
      .split('-')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
