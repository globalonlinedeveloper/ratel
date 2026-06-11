import 'dart:math';

/// Streak milestones that earn a celebration (Duolingo-style landmark days).
const Set<int> kStreakMilestones = {7, 30, 100, 365};

int? milestoneFor(int streak) =>
    kStreakMilestones.contains(streak) ? streak : null;

/// Villain roster by unit tier (the honey badger's real foes).
String villainForUnit(int unitIndex) {
  if (unitIndex < 2) return 'cobra';
  if (unitIndex < 4) return 'scorpion';
  if (unitIndex < 6) return 'bees';
  if (unitIndex < 8) return 'jackal';
  return 'vulture';
}

/// Correct-answer micro-reaction pool (anti-habituation): roughly 1 in 4
/// correct answers gets a small animated reaction; the hot-combo slot
/// (karate, combo >= 5) always wins. [roll] is 0..11.
String? pickReaction(int combo, int roll) {
  if (combo >= 5) return null;
  if (roll >= 3) return null;
  return const ['nod', 'fistpump', 'wink'][roll % 3];
}

/// Shuffled display order for [n] options. Content stores the correct choice
/// at index 0, so screens MUST render options through this permutation —
/// otherwise the right answer is always the first tile (gameable).
List<int> displayOrder(int n, Random rng) =>
    List<int>.generate(n, (i) => i)..shuffle(rng);

/// Villain ids with shipped battle art (incl. event-only villains).
const Set<String> kBattleVillains = {
  'cobra', 'scorpion', 'bees', 'jackal', 'vulture',
  'frostgolem', 'pumpkincrow', 'firecrackerimp',
};

/// Event override: a valid `event_villain` remote flag replaces the unit's
/// villain for the duration of an event (flip in app_flags, no redeploy).
/// Unknown/empty values fall back to the normal unit roster.
String villainFor(int unitIndex, String eventVillain) =>
    kBattleVillains.contains(eventVillain)
        ? eventVillain
        : villainForUnit(unitIndex);

/// Heart regeneration: +1 per [period] elapsed since [updatedAt], capped.
/// Returns the new count and the carried-forward timestamp (so partial
/// progress toward the next heart is never lost).
({int hearts, DateTime updatedAt}) regenHearts(
    int hearts, DateTime updatedAt, DateTime now,
    {int cap = 5, Duration period = const Duration(hours: 2)}) {
  if (hearts >= cap) return (hearts: cap, updatedAt: now);
  final int gained =
      now.difference(updatedAt).inMinutes ~/ period.inMinutes;
  if (gained <= 0) return (hearts: hearts, updatedAt: updatedAt);
  final int h = (hearts + gained) > cap ? cap : hearts + gained;
  return (
    hearts: h,
    updatedAt: h >= cap
        ? now
        : updatedAt.add(Duration(minutes: (h - hearts) * period.inMinutes)),
  );
}

/// Accuracy tier label for the completion chips.
String accuracyTier(int pct) =>
    pct >= 90 ? 'GREAT' : (pct >= 75 ? 'GOOD' : 'NICE');

/// Speed tier label for the completion chips.
String speedTier(Duration d) => d.inSeconds < 120
    ? 'BLAZING'
    : (d.inSeconds < 240 ? 'QUICK' : 'STEADY');

/// Full corrected sentence for the wrong-answer banner ('___' filled in).
String solutionText(String? sentence, String answer) {
  final s = sentence ?? '';
  return s.contains('___') ? s.replaceFirst('___', answer) : answer;
}

/// m:ss countdown formatting for heart-regen style timers.
String fmtCountdown(Duration d) {
  final int m = d.inMinutes;
  final int sec = d.inSeconds % 60;
  return '$m:${sec.toString().padLeft(2, '0')}';
}

/// +1 gem on every 5th correct-in-a-row (5, 10, 15...).
int comboGemBonus(int combo) => combo > 0 && combo % 5 == 0 ? 1 : 0;

/// Daily free chest: (gems, bonus label). Early birds (before 9:00) and
/// night owls (22:00+) get an extra gem and a cheering label.
(int, String) dailyChestReward(DateTime now) => now.hour < 9
    ? (3, 'Early bird bonus!')
    : now.hour >= 22
        ? (3, 'Night owl bonus!')
        : (2, '');

/// A CEFR-anchored course section: units [firstUnit..lastUnit] inclusive.
class CourseSection {
  const CourseSection(
      {required this.title,
      required this.cefr,
      required this.firstUnit,
      required this.lastUnit});

  final String title;
  final String cefr;
  final int firstUnit;
  final int lastUnit;
}

/// The course's shape (10 units today; lastUnit clamps for shorter
/// fallback courses, so the helpers never go out of range).
const List<CourseSection> kSections = [
  CourseSection(title: 'First steps', cefr: 'A1', firstUnit: 0, lastUnit: 2),
  CourseSection(title: 'Daily life', cefr: 'A2', firstUnit: 3, lastUnit: 5),
  CourseSection(
      title: 'Confident talk', cefr: 'B1', firstUnit: 6, lastUnit: 9),
];

/// The section containing unit [u] (the last section absorbs overflow).
CourseSection sectionForUnit(int u) {
  for (final s in kSections) {
    if (u >= s.firstUnit && u <= s.lastUnit) return s;
  }
  return kSections.last;
}

/// True when [u] is the first unit of its section (banner insertion).
bool startsSection(int u) =>
    kSections.any((s) => s.firstUnit == u);

/// 0-100 English Score: completion carries 90 points, streak up to 10.
int englishScore(
    {required int lessonsDone,
    required int lessonsTotal,
    required int streak}) {
  final int total = lessonsTotal < 1 ? 1 : lessonsTotal;
  final int done = lessonsDone > total ? total : lessonsDone;
  final int s = streak < 0 ? 0 : (streak > 10 ? 10 : streak);
  return done * 90 ~/ total + s;
}

/// CEFR band for a score: A1 <25, A2 <50, B1 <75, B2 otherwise.
String cefrFor(int score) => score < 25
    ? 'A1'
    : score < 50
        ? 'A2'
        : score < 75
            ? 'B1'
            : 'B2';

/// Points still needed to enter the next band (0 at B2).
int toNextBand(int score) =>
    score < 25 ? 25 - score : score < 50 ? 50 - score : score < 75 ? 75 - score : 0;
