/// Exercise types supported by the lesson player.
enum ExerciseType { choice, wordBank, typed }

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
