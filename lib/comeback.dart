/// Inc 134 — the triple-XP comeback boost (pure grant logic, fully testable).
///
/// A learner who was at lapse risk in the evening (18:00+, no XP yet) and
/// RETURNS the next morning gets a timed XP-boost window. The multiplier and
/// window length come from `app_flags` (`comeback_multiplier`,
/// `comeback_window_min`); the kill switch is `comeback_on`. Persistence
/// reuses the daily-chest boost prefs: `xp_boost_until` + `xp_boost_mult`
/// (whoever lights a boost owns BOTH prefs — the chest writes 2, the
/// comeback writes the flag value).
library;

String dayKey(DateTime d) => d.toIso8601String().substring(0, 10);

/// A lapse-risk evening: 18:00 or later with no XP earned yet today.
bool isEveningLapseRisk(DateTime now, int todayXp) =>
    now.hour >= 18 && todayXp == 0;

/// Grant only in the MORNING (before noon) directly after a flagged
/// lapse-risk day, and at most once per calendar day.
bool shouldGrantComeback({
  required DateTime now,
  required String? riskDay,
  required String? lastGrantDay,
}) {
  if (now.hour >= 12) return false;
  if (riskDay != dayKey(now.subtract(const Duration(days: 1)))) {
    return false;
  }
  return lastGrantDay != dayKey(now);
}
