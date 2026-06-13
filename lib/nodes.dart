import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// Loads the language-agnostic curriculum spine (`curriculum_nodes`, Inc
/// 145/148) so the English Score can weight per-skill mastery by CEFR band
/// without a redeploy. Mirrors the Flags/Art/Locales pattern: load once at
/// startup, 4s timeout, empty index when offline — in which case the score
/// falls back to the legacy completion formula (see AppState.englishScoreNode).
class Nodes {
  Nodes._();
  static final Nodes instance = Nodes._();

  /// node id -> CEFR band ('A1' | 'A2' | 'B1'), `state = 'live'` only.
  final Map<String, String> bands = {};

  Future<void> load() async {
    if (!Config.hasSupabase) return;
    try {
      final rows = await Supabase.instance.client
          .from('curriculum_nodes')
          .select('id,cefr,state')
          .eq('state', 'live')
          .timeout(const Duration(seconds: 4));
      ingest(List<Map<String, dynamic>>.from(rows));
    } catch (_) {
      // Empty index -> legacy score path. Never blocks startup.
    }
  }

  /// Pure, network-free fill (testable).
  void ingest(List<Map<String, dynamic>> rows) {
    final next = <String, String>{};
    for (final r in rows) {
      final id = (r['id'] ?? '').toString();
      final cefr = (r['cefr'] ?? '').toString();
      if (id.isNotEmpty && cefr.isNotEmpty) next[id] = cefr;
    }
    bands
      ..clear()
      ..addAll(next);
  }

  @visibleForTesting
  void debugSet(Map<String, String> b) {
    bands
      ..clear()
      ..addAll(b);
  }
}
