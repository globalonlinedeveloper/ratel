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
