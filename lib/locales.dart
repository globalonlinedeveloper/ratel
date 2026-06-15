import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// The UI-locale registry (`locales` table). Makes the language picker
/// DATA-DRIVEN: enabling a new UI language is a DB flip (`locales.enabled =
/// true`) with no app redeploy. It also owns the per-locale FALLBACK chain
/// (`locales.fallback`) so a variant — en-GB, ta-Latn, es-MX, fr-CA, … — stores
/// only its DELTAS and inherits the rest from its base; the `S` resolver walks
/// this chain. No language is special-cased: every variant uses the one
/// mechanism. Offline-first (Flags/S pattern): in-code defaults [en, ta] carry
/// the picker if the DB is slow or unreachable.
class Locales {
  Locales._();
  static final Locales instance = Locales._();

  /// Enabled locales in registry order. Defaults match today's two live UI
  /// languages so tests + offline always have a working picker.
  List<LocaleEntry> enabled = const [
    LocaleEntry('en', 'English'),
    LocaleEntry('ta', 'தமிழ்'),
  ];

  /// locale code -> its fallback (base) code, from the registry. A code absent
  /// here falls back to English; this is what makes en-GB->en and ta-Latn->ta
  /// the SAME mechanism (no English special-casing).
  Map<String, String> _fallback = const {};

  /// The base locale [code] inherits from. Unknown / self-referential codes
  /// resolve to 'en' (the English pivot), which terminates the resolver chain.
  String fallbackOf(String code) {
    final f = _fallback[code];
    return (f == null || f.isEmpty) ? 'en' : f;
  }

  Future<void> load() async {
    if (!Config.hasSupabase) return;
    try {
      // ALL locales (not only enabled): the fallback chain needs base rows even
      // when a base itself isn't offered in the picker.
      final rows = await Supabase.instance.client
          .from('locales')
          .select('code, native_name, enabled, fallback')
          .order('code')
          .timeout(const Duration(seconds: 4));
      ingest(List<Map<String, dynamic>>.from(rows));
    } catch (_) {
      // offline/slow: in-code defaults carry the picker
    }
  }

  /// Pure ingest (testable, no network). Builds the enabled picker list (rows
  /// flagged enabled) AND the fallback map (every row). Keeps the in-code
  /// defaults if the fetch yields no enabled rows, so the picker is never empty.
  void ingest(List<Map<String, dynamic>> rows) {
    final out = <LocaleEntry>[];
    final fb = <String, String>{};
    for (final r in rows) {
      final code = (r['code'] ?? '').toString();
      if (code.isEmpty) continue;
      final f = (r['fallback'] ?? '').toString();
      if (f.isNotEmpty) fb[code] = f;
      // Respect the enabled flag when present; rows without it (older test
      // fixtures) are treated as enabled for back-compat.
      final on = r.containsKey('enabled') ? (r['enabled'] == true) : true;
      if (!on) continue;
      final name = (r['native_name'] ?? '').toString();
      out.add(LocaleEntry(code, name.isEmpty ? code : name));
    }
    if (fb.isNotEmpty) _fallback = fb;
    // Inc 196 — picker order: English family first (US base, then variants),
    // then every other language A-Z by native name (Latin scripts first, then
    // grouped by script via Unicode order). Owner-chosen 'English first, A-Z'.
    out.sort((a, b) {
      int rank(String c) => c == 'en' ? 0 : (c.startsWith('en') ? 1 : 2);
      final r = rank(a.code) - rank(b.code);
      return r != 0 ? r : a.nativeName.toLowerCase().compareTo(b.nativeName.toLowerCase());
    });
    if (out.isNotEmpty) enabled = out;
  }


  /// Inc 196 — representative flag emoji for a locale code (picker affordance
  /// only). NB a flag is a COUNTRY, not a language: several Indian languages
  /// intentionally share IN. Falls back to a neutral white flag.
  static String flagFor(String code) {
    const m = <String, String>{'en': '🇺🇸', 'en-GB': '🇬🇧', 'en-IN': '🇮🇳', 'en-AU': '🇦🇺', 'es': '🇪🇸', 'es-US': '🇺🇸', 'fr': '🇫🇷', 'fr-CA': '🇨🇦', 'nl': '🇳🇱', 'nl-BE': '🇧🇪', 'de': '🇩🇪', 'it': '🇮🇹', 'pt': '🇧🇷', 'ru': '🇷🇺', 'uk': '🇺🇦', 'pl': '🇵🇱', 'cs': '🇨🇿', 'sk': '🇸🇰', 'sl': '🇸🇮', 'hr': '🇭🇷', 'sr': '🇷🇸', 'bg': '🇧🇬', 'ro': '🇷🇴', 'el': '🇬🇷', 'hu': '🇭🇺', 'fi': '🇫🇮', 'sv': '🇸🇪', 'da': '🇩🇰', 'nb': '🇳🇴', 'et': '🇪🇪', 'lt': '🇱🇹', 'lv': '🇱🇻', 'tr': '🇹🇷', 'id': '🇮🇩', 'sw': '🇰🇪', 'vi': '🇻🇳', 'th': '🇹🇭', 'ja': '🇯🇵', 'ko': '🇰🇷', 'zh': '🇨🇳', 'yue': '🇭🇰', 'hi': '🇮🇳', 'ta': '🇮🇳', 'ta-Latn': '🇮🇳', 'te': '🇮🇳', 'kn': '🇮🇳', 'ml': '🇮🇳', 'mr': '🇮🇳', 'gu': '🇮🇳', 'bn': '🇧🇩', 'pa': '🇮🇳'};
    return m[code] ?? '\u{1F3F3}\u{FE0F}';
  }

  void debugSet(List<LocaleEntry> e) => enabled = e;

  /// Test seam: set the fallback chain without a network.
  void debugSetFallback(Map<String, String> f) => _fallback = Map.of(f);
}

class LocaleEntry {
  const LocaleEntry(this.code, this.nativeName);
  final String code;
  final String nativeName;
}
