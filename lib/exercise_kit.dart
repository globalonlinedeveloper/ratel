import 'package:flutter/foundation.dart' show listEquals;

import 'models.dart';
import 'typed_match.dart';

/// Pure, per-type exercise logic. Every function is an EXHAUSTIVE switch
/// expression over [ExerciseType]: when a new type is added, the compiler
/// flags every site that needs a case — nothing falls through silently.

/// Whether the learner has produced something checkable.
bool canCheckAnswer(Exercise e,
    {int? selected, int pickedCount = 0, String typed = ''}) {
  return switch (e.type) {
    ExerciseType.choice => selected != null,
    ExerciseType.wordBank => pickedCount > 0,
    ExerciseType.typed || ExerciseType.listen => typed.trim().isNotEmpty,
    // match-pairs: checkable once every pair is locked in
    ExerciseType.matchPairs => pickedCount >= e.options.length,
  };
}

/// Grade the answer. [pickedWords] are the chosen word-bank tiles in order.
bool gradeAnswer(Exercise e,
    {int? selected, List<String> pickedWords = const [], String typed = ''}) {
  return switch (e.type) {
    ExerciseType.choice => selected == e.correctIndex,
    ExerciseType.wordBank => listEquals(pickedWords, e.correctOrder),
    ExerciseType.typed ||
    ExerciseType.listen =>
      typedAnswerMatches(typed, e.correctOrder),
    // completing the board IS the success; mistakes en route are
    // cosmetic (no hearts in matching - kindness by design)
    ExerciseType.matchPairs => true,
  };
}

/// The canonical correct answer to display.
String correctTextFor(Exercise e) {
  return switch (e.type) {
    ExerciseType.choice => e.options[e.correctIndex],
    ExerciseType.wordBank => e.correctOrder.join(' '),
    ExerciseType.typed ||
    ExerciseType.listen =>
      e.correctOrder.isNotEmpty ? e.correctOrder.first : '',
    ExerciseType.matchPairs => [
      for (int i = 0;
          i < e.options.length && i < e.correctOrder.length;
          i++)
        '${e.options[i]} — ${e.correctOrder[i]}'
    ].join(', '),
  };
}

/// What the learner answered, for the mistakes log.
String userTextFor(Exercise e,
    {int? selected, List<String> pickedWords = const [], String typed = ''}) {
  return switch (e.type) {
    ExerciseType.choice =>
      selected != null ? e.options[selected] : '(no answer)',
    ExerciseType.wordBank => pickedWords.join(' '),
    ExerciseType.typed || ExerciseType.listen => () {
        final t = typed.trim();
        return t.isEmpty ? '(no answer)' : t;
      }(),
    ExerciseType.matchPairs => 'all pairs matched',
  };
}

/// The explanation-key suffix (matches the bundled explanations format).
String explainSuffixFor(Exercise e, {int? selected}) {
  return switch (e.type) {
    ExerciseType.choice => '$selected',
    ExerciseType.wordBank => 'wb',
    ExerciseType.typed || ExerciseType.listen => 'ty',
    ExerciseType.matchPairs => 'mp',
  };
}
