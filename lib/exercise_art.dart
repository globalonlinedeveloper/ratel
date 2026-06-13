import 'models.dart';

/// Topic-matched exercise art (Inc 157). Pure + testable: maps an exercise to a
/// promoted object-art cell so a relevant illustration can sit above the prompt.
/// Only OBJECT theme sets feed the vocab (never the mascot/UI cells), and only
/// SAFE exercise types are illustrated (wordBank shows the sentence topic,
/// matchPairs the left item) so an image never reveals the answer.
const Set<String> kVocabSets = {'kt', 'ho', 'tr', 'mk', 'jb', 'md'};

const Set<ExerciseType> _safeTypes = {
  ExerciseType.wordBank,
  ExerciseType.matchPairs,
};

const Set<String> _stop = {
  'the', 'and', 'for', 'you', 'your', 'are', 'was', 'were', 'with', 'this',
  'that', 'have', 'has', 'had', 'can', 'will', 'from', 'they', 'she', 'his',
  'her', 'him', 'our', 'out', 'not', 'but', 'all', 'any', 'one', 'two', 'how',
  'what', 'who', 'why', 'when', 'where', 'here', 'there', 'its', 'their',
  'them', 'then', 'than', 'too', 'very', 'just', 'some', 'more', 'most',
};

/// Crude singular fold so "apples" (cell) and "apple" (sentence) match.
String _stem(String w) =>
    (w.length > 3 && w.endsWith('s')) ? w.substring(0, w.length - 1) : w;

/// stem(objectWord) -> art name, from the manifest [namePaths] (name->path),
/// restricted to the object [sets]. First cell wins on a stem collision.
Map<String, String> buildVocab(Map<String, String> namePaths,
    {Set<String> sets = kVocabSets}) {
  final out = <String, String>{};
  namePaths.forEach((name, path) {
    final slash = path.indexOf('/');
    final set = slash < 0 ? '' : path.substring(0, slash);
    if (!sets.contains(set)) return;
    final us = name.indexOf('_');
    if (us < 0) return;
    out.putIfAbsent(_stem(name.substring(us + 1).toLowerCase()), () => name);
  });
  return out;
}

/// The art cell to illustrate [ex], or null when there's no confident match
/// (the common case -> no image). Grammar items and answer-revealing types
/// (choice/typed/...) are never illustrated.
String? exerciseArt(Exercise ex, Map<String, String> vocab) {
  if (vocab.isEmpty || !_safeTypes.contains(ex.type)) return null;
  final src = ex.type == ExerciseType.wordBank ? ex.correctOrder : ex.options;
  for (final raw in src) {
    for (final w in raw.toLowerCase().split(RegExp(r'[^a-z]+'))) {
      if (w.length < 3 || _stop.contains(w)) continue;
      final hit = vocab[_stem(w)];
      if (hit != null) return hit;
    }
  }
  return null;
}

/// Every content word of [ex] (all types, all text fields except the
/// instruction prompt), lowercased and stop-filtered. Feeds the completion
/// recap below — the lesson is finished, so scanning answers reveals nothing.
Iterable<String> _contentWords(Exercise ex) sync* {
  final fields = <String>[
    if (ex.sentence != null) ex.sentence!,
    ...ex.options,
    ...ex.correctOrder,
  ];
  for (final raw in fields) {
    for (final w in raw.toLowerCase().split(RegExp(r'[^a-z]+'))) {
      if (w.length >= 3 && !_stop.contains(w)) yield w;
    }
  }
}

/// The deduped, in-order object-art cells practiced across a FINISHED lesson's
/// [exercises] (Inc 159 — the completion "concepts you practiced" strip).
/// Unlike [exerciseArt] this scans every exercise type and all content text
/// (no answer to reveal once the lesson is done); only object theme sets feed
/// [vocab], result capped at [max].
List<String> lessonConcepts(List<Exercise> exercises, Map<String, String> vocab,
    {int max = 8}) {
  if (vocab.isEmpty || exercises.isEmpty) return const [];
  final out = <String>[];
  final seen = <String>{};
  for (final ex in exercises) {
    for (final w in _contentWords(ex)) {
      final hit = vocab[_stem(w)];
      if (hit != null && seen.add(hit)) {
        out.add(hit);
        if (out.length >= max) return out;
      }
    }
  }
  return out;
}
