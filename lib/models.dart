import 'strings.dart';
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
  chat,
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

  /// A character speaks ([npcLine], shown as a bubble); the learner
  /// TYPES a free reply, graded leniently against [accepted].
  const Exercise.chat({
    required this.prompt,
    required String npcLine,
    required List<String> accepted,
  })  : type = ExerciseType.chat,
        sentence = npcLine,
        options = const [],
        correctIndex = -1,
        correctOrder = accepted;

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
  final String titleEn;
  final String titleTa; // Tamil draft (Inc 158); '' -> EN fallback
  final List<Exercise> exercises;
  const Lesson({
    required this.id,
    required String title,
    this.titleTa = '',
    required this.exercises,
  }) : titleEn = title;

  /// Locale-aware display title (Inc 158).
  String get title => S.instance.tr(titleEn, titleTa);
}

/// A unit groups lessons under a theme.
class Unit {
  final String titleEn;
  final String subtitleEn;
  final String titleTa; // Tamil drafts (Inc 158); '' -> EN fallback
  final String subtitleTa;
  final List<Lesson> lessons;
  const Unit({
    required String title,
    required String subtitle,
    this.titleTa = '',
    this.subtitleTa = '',
    required this.lessons,
  })  : titleEn = title,
        subtitleEn = subtitle;

  /// Locale-aware display strings (Inc 158).
  String get title => S.instance.tr(titleEn, titleTa);
  String get subtitle => S.instance.tr(subtitleEn, subtitleTa);
}
