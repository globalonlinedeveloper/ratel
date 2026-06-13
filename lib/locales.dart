import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// The enabled UI-locale registry (P1 `locales` table). Makes the language
/// picker DATA-DRIVEN: enabling a new UI language becomes a DB flip
/// (`locales.enabled = true`) with no app redeploy (Master Plan gap A).
/// Offline-first, mirroring the Flags/S pattern: in-code defaults [en, ta]
/// carry the picker if the DB is slow or unreachable.
class Locales {
  Locales._();
  static final Locales instance = Locales._();

  /// Enabled locales in registry order. Defaults match today's two live UI
  /// languages so tests + offline always have a working picker.
  List<LocaleEntry> enabled = const [
    LocaleEntry('en', 'English'),
    LocaleEntry('ta', 'தமிழ்'),
  ];

  Future<void> load() async {
    if (!Config.hasSupabase) return;
    try {
      final rows = await Supabase.instance.client
          .from('locales')
          .select('code, native_name, enabled')
          .eq('enabled', true)
          .timeout(const Duration(seconds: 4));
      ingest(List<Map<String, dynamic>>.from(rows));
    } catch (_) {
      // offline/slow: in-code defaults carry the picker
    }
  }

  /// Pure ingest (testable, no network). Keeps the in-code defaults if the
  /// fetch yields nothing, so the picker is never empty.
  void ingest(List<Map<String, dynamic>> rows) {
    final out = <LocaleEntry>[];
    for (final r in rows) {
      final code = (r['code'] ?? '').toString();
      if (code.isEmpty) continue;
      final name = (r['native_name'] ?? '').toString();
      out.add(LocaleEntry(code, name.isEmpty ? code : name));
    }
    if (out.isNotEmpty) enabled = out;
  }

  void debugSet(List<LocaleEntry> e) => enabled = e;
}

class LocaleEntry {
  const LocaleEntry(this.code, this.nativeName);
  final String code;
  final String nativeName;
}
