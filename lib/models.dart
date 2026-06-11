/// Exercise types supported by the lesson player.
enum ExerciseType {
  choice,
  wordBank,
  typed,
  listen,
  matchPairs,
  dialogueOrder,
  multiBlank,
  listenRespond,
}

/// A single exercise within a lesson.
class Exercise {
  final ExerciseType type;
  final String prompt; // instruction shown by Ratel
  final String? sentence; // optional sentence (may contain "___")
  final List<String> options; // choice: answers; wordBank: word tiles
  final int correctIndex; // choice only
  final List<String> correctOrder; // wordBank: order; typed: accepted answers

  const Exercise.choice({
    required this.prompt,
    this.sentence,
    required this.options,
    required this.correctIndex,
  })  : type = ExerciseType.choice,
        correctOrder = const [];

  const Exercise.wordBank({
    required this.prompt,
    required this.options,
    required this.correctOrder,
  })  : type = ExerciseType.wordBank,
        sentence = null,
        correctIndex = -1;

  /// A free-typing exercise. The learner types an answer; [accepted] holds the
  /// acceptable answers (matched case-insensitively, articles/punctuation
  /// tolerant). The first entry is treated as the canonical answer to display.
  const Exercise.typed({
    required this.prompt,
    this.sentence,
    required List<String> accepted,
  })  : type = ExerciseType.typed,
        options = const [],
        correctIndex = -1,
        correctOrder = accepted;

  /// A listening exercise ("type what you hear"): text-to-speech reads a short
  /// phrase aloud and the learner types it back. Graded like [Exercise.typed]
  /// (lenient match against [accepted], whose first entry is spoken).
  /// Match the pairs: [left] aligns index-wise with [right]
  /// (stored as options / correctOrder so DB columns reuse cleanly).
  const Exercise.matchPairs({
    required this.prompt,
    required List<String> left,
    required List<String> right,
  })  : type = ExerciseType.matchPairs,
        sentence = null,
        options = left,
        correctIndex = -1,
        correctOrder = right;

  /// Order the conversation: [lines] are the tiles (shuffled at
  /// display) and [correctOrder] is the conversation in sequence.
  const Exercise.dialogueOrder({
    required this.prompt,
    required List<String> lines,
    required this.correctOrder,
  })  : type = ExerciseType.dialogueOrder,
        sentence = null,
        options = lines,
        correctIndex = -1;

  /// Fill N blanks IN ORDER: [template] contains '___' per blank;
  /// [answers] (subset of [options]) fill them left to right.
  const Exercise.multiBlank({
    required this.prompt,
    required String template,
    required this.options,
    required List<String> answers,
  })  : type = ExerciseType.multiBlank,
        sentence = template,
        correctIndex = -1,
        correctOrder = answers;

  /// Hear a line (never shown), pick the right RESPONSE.
  const Exercise.listenRespond({
    required this.prompt,
    required String say,
    required this.options,
    required this.correctIndex,
  })  : type = ExerciseType.listenRespond,
        sentence = say,
        correctOrder = const [];

  const Exercise.listen({
    required this.prompt,
    required List<String> accepted,
  })  : type = ExerciseType.listen,
        sentence = null,
        options = const [],
        correctIndex = -1,
        correctOrder = accepted;
}

/// A lesson is an ordered list of exercises.
class Lesson {
  final String id;
  final String title;
  final List<Exercise> exercises;
  const Lesson({required this.id, required this.title, required this.exercises});
}

/// A unit groups lessons under a theme.
class Unit {
  final String title;
  final String subtitle;
  final List<Lesson> lessons;
  const Unit({required this.title, required this.subtitle, required this.lessons});
}
