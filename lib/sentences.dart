import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'locales.dart';

/// Reuse layer (Inc 202). Curated example SENTENCES, meaning-anchored: each
/// [SentenceEntry] is one English sentence whose `meaning_id` namespaces it to
/// a unit (e.g. `sent:u1.how-are-you`), plus its translated MEANING per
/// language. Loaded at startup from the public-read `sentences` table; powers
/// the Guidebook 'Example sentences' section + the lesson-complete phrases
/// recap. Offline/empty -> forUnit returns [] and the surfaces render nothing.
class SentenceEntry {
  SentenceEntry(this.meaningId, this.unit, this.en, this.meanings);
  final String meaningId;
  final String unit; // 'u1'..'u11', parsed from meaning_id
  final String en; // the English sentence (lang == 'en')
  final Map<String, String> meanings; // lang -> translated meaning
}

/// Unit token from a `sent:<unit>.<slug>` meaning_id (or '').
String sentenceUnitOf(String meaningId) {
  final m = RegExp(r'^sent:([^.]+)\.').firstMatch(meaningId);
  return m == null ? '' : m.group(1)!;
}

/// Unit id from a lesson id like 'u1l3' -> 'u1' (or '' when it doesn't match).
String unitOfLessonId(String lessonId) {
  final m = RegExp(r'^(u\d+)l\d+').firstMatch(lessonId);
  return m == null ? '' : m.group(1)!;
}

/// A sentence's MEANING in [lang], resolved through the locale fallback chain
/// (es-US->es, fr-CA->fr, ...). EN never self-glosses -> null.
String? sentenceMeaning(SentenceEntry e, String lang) {
  var cur = lang;
  final seen = <String>{};
  while (cur.isNotEmpty && cur != 'en' && seen.add(cur)) {
    final v = e.meanings[cur];
    if (v != null && v.isNotEmpty) return v;
    final next = Locales.instance.fallbackOf(cur);
    if (next == cur) break;
    cur = next;
  }
  return null;
}

/// Startup-loaded reuse-layer index. Mirrors the Concepts/Flags/S singleton.
class Sentences {
  Sentences._();
  static final Sentences instance = Sentences._();

  final Map<String, List<SentenceEntry>> _byUnit = {};

  Future<void> load() async {
    if (!Config.hasSupabase) return;
    try {
      final rows = await Supabase.instance.client
          .from('sentences')
          .select('meaning_id, lang, text')
          .timeout(const Duration(seconds: 5));
      ingest(List<Map<String, dynamic>>.from(rows as List));
    } catch (_) {
      // offline-first: empty index -> the surfaces stay hidden.
    }
  }

  /// Pure ingest (testable, no network): group rows by meaning_id into
  /// per-unit lists. Only meanings with an English anchor become entries.
  @visibleForTesting
  void ingest(List<Map<String, dynamic>> rows) {
    final en = <String, String>{};
    final meanings = <String, Map<String, String>>{};
    for (final r in rows) {
      final mid = (r['meaning_id'] ?? '').toString();
      final lang = (r['lang'] ?? '').toString();
      final text = (r['text'] ?? '').toString();
      if (mid.isEmpty || lang.isEmpty || text.isEmpty) continue;
      if (lang == 'en') {
        en[mid] = text;
      } else {
        (meanings[mid] ??= <String, String>{})[lang] = text;
      }
    }
    final units = <String, List<SentenceEntry>>{};
    final ids = en.keys.toList()..sort();
    for (final id in ids) {
      final unit = sentenceUnitOf(id);
      if (unit.isEmpty) continue;
      units.putIfAbsent(unit, () => <SentenceEntry>[]).add(
          SentenceEntry(id, unit, en[id]!, meanings[id] ?? <String, String>{}));
    }
    _byUnit
      ..clear()
      ..addAll(units);
  }

  /// The unit's example sentences (English anchor present), meaning_id order.
  List<SentenceEntry> forUnit(String unitId) => _byUnit[unitId] ?? const [];

  @visibleForTesting
  void debugSet(Map<String, List<SentenceEntry>> byUnit) {
    _byUnit
      ..clear()
      ..addAll(byUnit);
  }
}
