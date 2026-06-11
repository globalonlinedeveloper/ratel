import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// Remote config / feature flags from the public-read `app_flags` table
/// (migration 024). Flip behavior live without a redeploy; defaults keep the
/// app fully functional offline or before load. Admin write = is_admin RLS.
class Flags {
  Flags._();
  static final Flags instance = Flags._();

  final Map<String, String> _v = {};

  Future<void> load() async {
    if (!Config.hasSupabase) return;
    try {
      final rows = await Supabase.instance.client
          .from('app_flags')
          .select('key,val')
          .timeout(const Duration(seconds: 5));
      for (final r in rows) {
        _v[(r['key'] ?? '').toString()] = (r['val'] ?? '').toString();
      }
    } catch (_) {
      // Defaults stand.
    }
  }

  /// Empty values mean "unset" — the in-code default applies. (A blank
  /// seeded row once blanked the nudge banner and paywall prices.)
  String str(String key, String def) {
    final s = _v[key];
    return (s == null || s.isEmpty) ? def : s;
  }

  bool flag(String key, bool def) {
    final s = _v[key];
    if (s == null || s.isEmpty) return def;
    return s == 'true' || s == '1';
  }

  int intOf(String key, int def) => int.tryParse(_v[key] ?? '') ?? def;

  @visibleForTesting
  void debugSet(Map<String, String> values) {
    _v
      ..clear()
      ..addAll(values);
  }
}
