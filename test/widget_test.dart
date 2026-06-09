import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';
import 'package:ratel/content.dart';
import 'package:ratel/models.dart';
import 'package:ratel/sfx.dart';

void main() {
  test('combo ladder rises then caps, resets on wrong', () {
    final c = ComboCounter();
    expect(c.onCorrect(), 0);
    expect(c.onCorrect(), 1);
    expect(c.onCorrect(), 2);
    expect(c.onCorrect(), 3);
    expect(c.onCorrect(), 4);
    expect(c.onCorrect(), 4);
    c.onWrong();
    expect(c.value, 0);
    expect(c.onCorrect(), 0);
  });

  test('completeLesson adds XP and marks the lesson complete', () {
    final state = AppState();
    expect(state.xp, 0);
    expect(state.isCompleted('u1l1'), isFalse);

    state.completeLesson('u1l1', 40);

    expect(state.xp, 40);
    expect(state.isCompleted('u1l1'), isTrue);
    expect(state.completedCount, 1);
  });

  test('reset clears all progress', () {
    final state = AppState();
    state.completeLesson('u1l1', 40);
    state.reset();

    expect(state.xp, 0);
    expect(state.isCompleted('u1l1'), isFalse);
    expect(state.completedCount, 0);
  });

  test('course has four units with twenty unique lesson ids', () {
    expect(course.length, 4);
    final ids = [for (final u in course) ...u.lessons.map((l) => l.id)];
    expect(ids.length, 20);
    expect(ids.toSet().length, ids.length); // no duplicate ids
  });

  test('every exercise is well-formed', () {
    for (final unit in course) {
      for (final lesson in unit.lessons) {
        expect(lesson.exercises, isNotEmpty);
        for (final ex in lesson.exercises) {
          if (ex.type == ExerciseType.choice) {
            expect(ex.options.length, greaterThanOrEqualTo(2));
            expect(ex.correctIndex, inInclusiveRange(0, ex.options.length - 1));
          } else {
            // wordBank: the answer must be buildable from the given tiles.
            expect(ex.correctOrder, isNotEmpty);
            final bank = [...ex.options];
            for (final word in ex.correctOrder) {
              expect(bank.remove(word), isTrue,
                  reason: 'tile "$word" missing for "${ex.prompt}"');
            }
          }
        }
      }
    }
  });
}
