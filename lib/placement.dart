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
