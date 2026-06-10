/// Streak milestones that earn a celebration (Duolingo-style landmark days).
const Set<int> kStreakMilestones = {7, 30, 100, 365};

int? milestoneFor(int streak) =>
    kStreakMilestones.contains(streak) ? streak : null;

/// Correct-answer micro-reaction pool (anti-habituation): roughly 1 in 4
/// correct answers gets a small animated reaction; the hot-combo slot
/// (karate, combo >= 5) always wins. [roll] is 0..11.
String? pickReaction(int combo, int roll) {
  if (combo >= 5) return null;
  if (roll >= 3) return null;
  return const ['nod', 'fistpump', 'wink'][roll % 3];
}
