import 'package:flutter/material.dart';
import 'app_state.dart';

/// Which running stat an achievement is measured against.
enum AchMetric { lessons, streak, xp }

/// A milestone badge, earned the moment the matching stat crosses [threshold].
/// Computed live from [AppState] — no extra tables or writes.
class Achievement {
  const Achievement(
      this.title, this.description, this.icon, this.metric, this.threshold);

  final String title;
  final String description;
  final IconData icon;
  final AchMetric metric;
  final int threshold;
}

const List<Achievement> achievements = [
  Achievement('First steps', 'Finish your first lesson', Icons.flag,
      AchMetric.lessons, 1),
  Achievement('Warming up', 'Finish 5 lessons', Icons.local_library,
      AchMetric.lessons, 5),
  Achievement('Scholar', 'Finish 10 lessons', Icons.school, AchMetric.lessons,
      10),
  Achievement('Completionist', 'Finish 20 lessons', Icons.workspace_premium,
      AchMetric.lessons, 20),
  Achievement('On a roll', 'Reach a 3-day streak',
      Icons.local_fire_department, AchMetric.streak, 3),
  Achievement('Unstoppable', 'Reach a 7-day streak', Icons.bolt,
      AchMetric.streak, 7),
  Achievement('Centurion', 'Earn 100 XP', Icons.military_tech, AchMetric.xp,
      100),
  Achievement('XP hunter', 'Earn 500 XP', Icons.emoji_events, AchMetric.xp,
      500),
];

int valueFor(AchMetric m, AppState s) {
  switch (m) {
    case AchMetric.lessons:
      return s.completedCount;
    case AchMetric.streak:
      return s.streak;
    case AchMetric.xp:
      return s.xp;
  }
}

bool isEarned(Achievement a, AppState s) => valueFor(a.metric, s) >= a.threshold;
