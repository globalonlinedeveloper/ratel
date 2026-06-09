import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app_state.dart';

void main() {
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
}
