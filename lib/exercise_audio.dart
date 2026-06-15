import 'models.dart';

/// Phase 2.1 — answer-reveal-safe audio for the exercise page.
///
/// Every item should be hearable (dual coding / comprehensible input), but
/// speaking the *target* of a build-or-order item (wordBank/dialogue) or a
/// blank template (multiBlank) would hand the learner the answer. So the
/// PRE-answer speaker is offered only for stimulus text that is already on
/// screen and safe to hear; the full solution is replayed AFTER answering
/// (nothing left to reveal). Mirrors the safety reasoning in
/// `exercise_art.dart`.
///
/// Returns the text to speak before the learner answers, or null when there is
/// no answer-safe stimulus. `listen`/`listenRespond` return null here because
/// their bodies own a dedicated Play button (audio IS the exercise).
String? audioStimulus(Exercise ex) {
  switch (ex.type) {
    case ExerciseType.choice:
    case ExerciseType.typed:
    case ExerciseType.chat:
      final s = ex.sentence;
      return (s != null && s.trim().isNotEmpty) ? spokenText(s) : null;
    case ExerciseType.listen:
    case ExerciseType.listenRespond:
    case ExerciseType.wordBank:
    case ExerciseType.dialogueOrder:
    case ExerciseType.multiBlank:
    case ExerciseType.matchPairs:
      return null;
  }
}

/// Normalize text for speech: blanks ("___") become a short pause and runs of
/// whitespace collapse, so TTS never literally voices underscores.
String spokenText(String s) =>
    s.replaceAll(RegExp(r'_+'), ' … ').replaceAll(RegExp(r'\s+'), ' ').trim();
