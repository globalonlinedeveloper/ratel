import 'models.dart';
import 'content.dart';

/// Placement ("test out") logic — pure functions, unit-tested.
///
/// Probes sample one choice-exercise from lessons across Units 2-5 so a
/// learner with prior English can skip the basics. Selection is by lesson id
/// (not index) so content edits don't silently break it.
const List<String> placementLessonIds = [
  'u2l1', 'u2l3', 'u3l2', 'u3l5', 'u4l2', 'u4l5', 'u5l2', 'u5l3',
];

class PlacementProbe {
  final String lessonId;
  final Exercise exercise;
  const PlacementProbe(this.lessonId, this.exercise);
}

/// First choice-type exercise of each probe lesson (skips anything missing).
List<PlacementProbe> buildPlacementProbes() {
  final probes = <PlacementProbe>[];
  for (final id in placementLessonIds) {
    for (final unit in course) {
      for (final lesson in unit.lessons) {
        if (lesson.id != id) continue;
        for (final ex in lesson.exercises) {
          if (ex.type == ExerciseType.choice) {
            probes.add(PlacementProbe(id, ex));
            break;
          }
        }
      }
    }
  }
  return probes;
}

/// How many leading units to skip for [correct] of [total] answers.
int unitsToSkipFor(int correct, int total) {
  if (total <= 0) return 0;
  final f = correct / total;
  if (f >= 0.85) return 3;
  if (f >= 0.6) return 2;
  if (f >= 0.35) return 1;
  return 0;
}

/// Every lesson id in the first [n] units of the active course.
List<String> lessonIdsForUnits(int n) => [
      for (final unit in course.take(n)) ...unit.lessons.map((l) => l.id),
    ];

/// Probes for a SECTION test-out: up to [cap] choice exercises sampled
/// evenly across the units being skipped (0..firstUnit-1). By lesson id
/// via the course walk, so content edits don't break it.
List<PlacementProbe> sectionProbes(int firstUnit, {int cap = 8}) {
  final probes = <PlacementProbe>[];
  final units = course.take(firstUnit).toList();
  if (units.isEmpty) return probes;
  // walk lessons round-robin across units so coverage spreads
  int li = 0;
  while (probes.length < cap) {
    bool any = false;
    for (final unit in units) {
      if (li >= unit.lessons.length) continue;
      any = true;
      final lesson = unit.lessons[li];
      for (final ex in lesson.exercises) {
        if (ex.type == ExerciseType.choice) {
          probes.add(PlacementProbe(lesson.id, ex));
          break;
        }
      }
      if (probes.length >= cap) break;
    }
    if (!any) break;
    li++;
  }
  return probes;
}

/// Pass rule for a section test-out: at least 85% correct.
bool sectionTestPassed(int correct, int total) =>
    total > 0 && correct * 100 >= total * 85;
