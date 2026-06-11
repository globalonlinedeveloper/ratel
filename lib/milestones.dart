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
