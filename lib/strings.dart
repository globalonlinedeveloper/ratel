import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// Server-driven copy + the i18n seam (Tamil reads the `ta` column).
/// Mirrors the Flags pattern: in-code defaults ALWAYS apply when a row
/// or column is empty, so the app can never show a blank string.
class S {
  S._();
  static final S instance = S._();

  /// Active locale column: 'en' now, 'ta' when the Tamil layer lands.
  String locale = 'en';

  final Map<String, Map<String, String>> _rows = {};

  Future<void> load() async {
    if (!Config.hasSupabase) return;
    try {
      final rows = await Supabase.instance.client
          .from('app_strings')
          .select('key, en, ta')
          .timeout(const Duration(seconds: 4));
      for (final r in rows) {
        _rows[(r['key'] ?? '').toString()] = {
          'en': (r['en'] ?? '').toString(),
          'ta': (r['ta'] ?? '').toString(),
        };
      }
    } catch (_) {
      // offline/slow: in-code defaults carry the app
    }
  }

  /// The localized server string for [key], or [def] when unset/empty
  /// (empty means unset — the Inc 85 lesson, baked in from day one).
  String t(String key, String def) {
    final row = _rows[key];
    if (row == null) return def;
    final v = row[locale] ?? '';
    if (v.isNotEmpty) return v;
    final en = row['en'] ?? '';
    return en.isNotEmpty ? en : def; // locale column empty -> en -> default
  }

  /// Test injection.
  void debugSet(String key, {String en = '', String ta = ''}) {
    _rows[key] = {'en': en, 'ta': ta};
  }

  void debugClear() => _rows.clear();
}
