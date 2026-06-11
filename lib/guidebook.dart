import 'milestones.dart';
import 'models.dart';

/// (lessonTitle, keyPhrase) per lesson — derived from the content, no
/// authoring required. Exhaustive over ExerciseType (the kit pattern).
List<(String, String)> guidebookFor(Unit unit) =>
    [for (final l in unit.lessons) (l.title, keyPhraseFor(l))];

/// The first exercise that yields a real phrase wins; the lesson title
/// is the graceful fallback.
String keyPhraseFor(Lesson l) {
  for (final e in l.exercises) {
    final String t = switch (e.type) {
      ExerciseType.choice => (e.sentence ?? '').contains('___')
          ? solutionText(e.sentence, e.options[e.correctIndex])
          : '',
      ExerciseType.wordBank => e.correctOrder.join(' '),
      ExerciseType.dialogueOrder => e.correctOrder.join('  ·  '),
      ExerciseType.typed ||
      ExerciseType.listen =>
        e.correctOrder.isNotEmpty ? e.correctOrder.first : '',
      ExerciseType.matchPairs => '',
    };
    if (t.isNotEmpty) return t;
  }
  return l.title;
}
