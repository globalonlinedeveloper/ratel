import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'locales.dart';

/// Reuse layer (Inc 182, Phase 3.1). A language-neutral catalogue of meanings:
/// each [ConceptEntry] is optionally illustrated by an object-art cell
/// ([artName], RatelArt-renderable) and named per language in [terms]. Loaded
/// at startup from the public-read `concepts` + `concept_terms` tables; powers
/// the tap-a-word picture + meaning sheet (2.3) and is the spine for audio.
/// Offline/empty -> lookups return null and the sheet stays text-only.
class ConceptEntry {
  ConceptEntry(this.id, this.artName, this.terms);
  final String id;
  final String? artName; // art_manifest name, or null when no picture yet
  final Map<String, String> terms; // lang -> primary term
}

/// What a tapped word resolves to: the matched concept's picture + the meaning
/// in the requested language (null when that language has no term yet).
class ConceptHit {
  ConceptHit({required this.id, this.artName, this.headword, this.meaning});
  final String id;
  final String? artName;
  final String? headword; // canonical EN term (the lemma)
  final String? meaning; // term in the requested meaning language (e.g. 'ta')
  bool get hasArt => artName != null && artName!.isNotEmpty;
  bool get hasMeaning => meaning != null && meaning!.isNotEmpty;
  bool get isEmpty => !hasArt && !hasMeaning;
}

/// Crude singular fold; mirrors exercise_art._stem so "apples" matches "apple".
String conceptStem(String w) =>
    (w.length > 3 && w.endsWith('s')) ? w.substring(0, w.length - 1) : w;

/// Letters-only, lowercased — matches WordTapText's cleaned tapped word.
String conceptClean(String w) =>
    w.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

/// Pure: EN-term lookup (raw + stemmed key) from concept entries -> concept id.
Map<String, String> buildEnTermIndex(Iterable<ConceptEntry> concepts) {
  final out = <String, String>{};
  for (final c in concepts) {
    final en = c.terms['en'];
    if (en == null || en.isEmpty) continue;
    final low = en.toLowerCase();
    out.putIfAbsent(low, () => c.id);
    out.putIfAbsent(conceptStem(low), () => c.id);
  }
  return out;
}

/// Pure: resolve [word] to a [ConceptHit] via [index] (enTerm->id) + [byId];
// Inc 198 -- resolve a concept meaning through the locale fallback chain so a
// variant learner (es-US->es, fr-CA->fr, nl-BE->nl) inherits its base meaning.
String? _meaningFor(ConceptEntry c, String lang) {
  var cur = lang;
  final seen = <String>{};
  while (cur.isNotEmpty && cur != 'en' && seen.add(cur)) {
    final v = c.terms[cur];
    if (v != null && v.isNotEmpty) return v;
    final next = Locales.instance.fallbackOf(cur);
    if (next == cur) break;
    cur = next;
  }
  return null;
}

/// the meaning line uses [meaningLang] (skipped for 'en' — no self-gloss).
/// Null when no concept matches (the common case -> graceful, no enrichment).
ConceptHit? lookupConcept(
  String word,
  Map<String, String> index,
  Map<String, ConceptEntry> byId, {
  String meaningLang = 'ta',
}) {
  final clean = conceptClean(word);
  if (clean.isEmpty) return null;
  final id = index[clean] ?? index[conceptStem(clean)];
  if (id == null) return null;
  final c = byId[id];
  if (c == null) return null;
  return ConceptHit(
    id: id,
    artName: c.artName,
    headword: c.terms['en'],
    meaning: meaningLang == 'en' ? null : _meaningFor(c, meaningLang),
  );
}

/// Startup-loaded reuse-layer index. Mirrors the Art/Flags/S singleton pattern.
class Concepts {
  Concepts._();
  static final Concepts instance = Concepts._();

  final Map<String, ConceptEntry> _byId = {};
  Map<String, String> _enIndex = {};

  Future<void> load() async {
    if (!Config.hasSupabase) return;
    try {
      final c = Supabase.instance.client;
      final res = await Future.wait([
        c.from('concepts').select('id, art_name'),
        c.from('concept_terms').select('concept_id, lang, term, is_primary'),
      ]).timeout(const Duration(seconds: 5));
      _ingest(
        List<Map<String, dynamic>>.from(res[0] as List),
        List<Map<String, dynamic>>.from(res[1] as List),
      );
    } catch (_) {
      // Defaults stand: empty index, text-only sheet (offline-first).
    }
  }

  /// Pure ingest of `concepts` + `concept_terms` rows into the index.
  void _ingest(List<Map<String, dynamic>> concepts,
      List<Map<String, dynamic>> terms) {
    final tmp = <String, ConceptEntry>{};
    for (final r in concepts) {
      final id = (r['id'] ?? '').toString();
      if (id.isEmpty) continue;
      final art = (r['art_name'] ?? '').toString();
      tmp[id] = ConceptEntry(id, art.isEmpty ? null : art, {});
    }
    for (final r in terms) {
      final cid = (r['concept_id'] ?? '').toString();
      final lang = (r['lang'] ?? '').toString();
      final term = (r['term'] ?? '').toString();
      final e = tmp[cid];
      if (e == null || lang.isEmpty || term.isEmpty) continue;
      if (r['is_primary'] == true || !e.terms.containsKey(lang)) {
        e.terms[lang] = term;
      }
    }
    _byId
      ..clear()
      ..addAll(tmp);
    _enIndex = buildEnTermIndex(_byId.values);
  }

  /// Resolve a tapped [word] -> picture + meaning, or null (graceful).
  ConceptHit? lookup(String word, {String? meaningLang}) =>
      lookupConcept(word, _enIndex, _byId, meaningLang: meaningLang ?? 'ta');

  @visibleForTesting
  void debugSet(List<ConceptEntry> entries) {
    _byId
      ..clear()
      ..addEntries(entries.map((e) => MapEntry(e.id, e)));
    _enIndex = buildEnTermIndex(_byId.values);
  }
}
