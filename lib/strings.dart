import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// Server-driven copy + the i18n seam.
///
/// P1 (Inc 144): UI strings live long-format in `app_strings_tr`
/// (key, locale, val) — adding a UI language is now INSERT-only, with no schema
/// or loader change. In-code defaults (the `def` arg of [t]) remain the English
/// PIVOT and ALWAYS apply when a row/locale is empty, so the app never shows a
/// blank string and existing EN tests stay byte-identical. A back-compat wide
/// view keeps already-deployed clients working; new clients read the long table.
class S {
  S._();
  static final S instance = S._();

  /// Active app locale (BCP-47 language subtag): 'en', 'ta', …
  String locale = 'en';

  /// Test-only pseudo-locale: inflates every resolved string ~40% with accents
  /// to surface layout overflow before a real long language ships (plan §9.4).
  bool pseudo = false;

  /// key -> { locale -> value }
  final Map<String, Map<String, String>> _rows = {};

  Future<void> load() async {
    if (!Config.hasSupabase) return;
    try {
      final rows = await Supabase.instance.client
          .from('app_strings_tr')
          .select('key, locale, val')
          // All enabled-locale rows (tiny today: en+ta). FUTURE: when many
          // locales enable, filter by the enabled set or paginate.
          .limit(20000)
          .timeout(const Duration(seconds: 4));
      ingestRows(List<Map<String, dynamic>>.from(rows));
    } catch (_) {
      // offline/slow: in-code defaults carry the app
    }
  }

  /// Pure ingest of long-format (key, locale, val) rows into [_rows].
  /// Extracted so the loader logic is unit-testable without a network.
  void ingestRows(List<Map<String, dynamic>> rows) {
    for (final r in rows) {
      final k = (r['key'] ?? '').toString();
      if (k.isEmpty) continue;
      final loc = (r['locale'] ?? '').toString();
      if (loc.isEmpty) continue;
      (_rows[k] ??= <String, String>{})[loc] = (r['val'] ?? '').toString();
    }
  }

  /// The localized server string for [key], or [def] when unset/empty
  /// (empty means unset — the Inc 85 lesson, baked in from day one).
  String t(String key, String def) {
    final base = _resolve(key, def);
    return pseudo ? _pseudoize(base) : base;
  }

  String _resolve(String key, String def) {
    final row = _rows[key];
    if (row == null) return def;
    final v = row[locale] ?? '';
    if (v.isNotEmpty) return v;
    final en = row['en'] ?? '';
    return en.isNotEmpty ? en : def; // locale empty -> en -> in-code default
  }

  // ---------------------------------------------------------------------------
  // Plural engine — CLDR categories + ICU-style selection (Invariant 10c).
  // Landed once, before UI language #3, so plural-correct copy is an INSERT.
  // ---------------------------------------------------------------------------

  /// CLDR cardinal plural category for [n] under [loc] (language subtag honored).
  /// Source: Unicode CLDR Language Plural Rules. Covers the enabled + near-term
  /// locales; unknown languages fall back to the English rule. `locales`
  /// .plural_categories declares which branches a translator must supply.
  static String pluralCategory(String loc, num n) {
    final lang = loc.split(RegExp(r'[-_]')).first.toLowerCase();
    final abs = n.abs();
    final i = abs.floor();
    switch (lang) {
      case 'ta': // Tamil: one <- i = 0 or n = 1
      case 'hi': // Hindi: one <- i = 0 or n = 1
        return (i == 0 || abs == 1) ? 'one' : 'other';
      case 'en':
      default: // English-like: one <- n = 1
        return abs == 1 ? 'one' : 'other';
    }
  }

  /// Plural- and number-aware lookup. [def] is the English source (it may itself
  /// carry ICU plural syntax). Selects the CLDR branch for [n] in the active
  /// locale, then substitutes `{n}` / `#` with the number.
  String plural(String key, String def, num n) {
    final raw = _resolve(key, def);
    final branch = selectPlural(raw, pluralCategory(locale, n), n);
    final filled = branch.replaceAll('{n}', '$n').replaceAll('#', '$n');
    return pseudo ? _pseudoize(filled) : filled;
  }

  static final RegExp _pluralRe =
      RegExp(r'\{\s*[A-Za-z0-9_]+\s*,\s*plural\s*,');

  /// Resolves an ICU `{arg, plural, … }` block to the branch for [cat]/[n].
  /// Supports `=N` exact matches and CLDR category keywords; returns the input
  /// unchanged when it carries no plural block. Brace-aware (branch text may
  /// contain `{n}`). Public for unit testing.
  static String selectPlural(String s, String cat, num n) {
    final m = _pluralRe.firstMatch(s);
    if (m == null) return s;
    final open = m.start;
    final branchesStart = m.end;
    int depth = 0;
    int end = -1;
    for (int idx = open; idx < s.length; idx++) {
      final ch = s[idx];
      if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) {
          end = idx;
          break;
        }
      }
    }
    if (end < 0) return s;
    final branches = _parseBranches(s.substring(branchesStart, end));
    final exact = n == n.truncate() ? '=${n.toInt()}' : '=$n';
    final chosen = branches[exact] ?? branches[cat] ?? branches['other'] ?? '';
    return s.substring(0, open) + chosen + s.substring(end + 1);
  }

  static Map<String, String> _parseBranches(String body) {
    final out = <String, String>{};
    int i = 0;
    while (i < body.length) {
      while (i < body.length && _isWs(body.codeUnitAt(i))) {
        i++;
      }
      final selStart = i;
      while (i < body.length && body[i] != '{') {
        i++;
      }
      if (i >= body.length) break;
      final sel = body.substring(selStart, i).trim();
      int depth = 0;
      final textStart = i + 1;
      int j = i;
      for (; j < body.length; j++) {
        if (body[j] == '{') {
          depth++;
        } else if (body[j] == '}') {
          depth--;
          if (depth == 0) break;
        }
      }
      if (j >= body.length) break;
      if (sel.isNotEmpty) out[sel] = body.substring(textStart, j);
      i = j + 1;
    }
    return out;
  }

  static bool _isWs(int c) => c == 32 || c == 9 || c == 10 || c == 13;

  static const String _accents = 'áàâäéèêëíìîïóòôöúùûü';

  static String _pseudoize(String s) {
    if (s.isEmpty) return s;
    final extra = (s.runes.length * 0.4).round().clamp(2, 24);
    final sb = StringBuffer(s)..write(' ');
    for (var i = 0; i < extra; i++) {
      sb.write(_accents[i % _accents.length]);
    }
    return sb.toString();
  }

  /// Persisted choice; restored by [restoreLocale] at startup.
  Future<void> setLocale(String l) async {
    locale = l == 'ta' ? 'ta' : 'en';
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('app_locale', locale);
    } catch (_) {}
  }

  Future<void> restoreLocale() async {
    try {
      final p = await SharedPreferences.getInstance();
      final l = p.getString('app_locale');
      if (l == 'ta') locale = 'ta';
    } catch (_) {}
  }

  /// Test injection (wide convenience: sets en and/or ta).
  void debugSet(String key, {String en = '', String ta = ''}) {
    _rows[key] = {'en': en, 'ta': ta};
  }

  /// Test injection of a single (key, locale, value) — long-format aware.
  void debugSetLocale(String key, String loc, String val) {
    (_rows[key] ??= <String, String>{})[loc] = val;
  }

  void debugClear() => _rows.clear();
}
