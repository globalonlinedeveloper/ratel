import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/exercise_kit.dart';
import 'package:ratel/models.dart';

void main() {
  const choice = Exercise.choice(
      prompt: 'p', options: ['a', 'b', 'c'], correctIndex: 1);
  const bank = Exercise.wordBank(
      prompt: 'p', options: ['x', 'y'], correctOrder: ['y', 'x']);
  const typed = Exercise.typed(prompt: 'p', accepted: ['hello', 'hi']);
  const listen = Exercise.listen(prompt: 'p', accepted: ['water']);

  test('canCheckAnswer per type', () {
    expect(canCheckAnswer(choice), false);
    expect(canCheckAnswer(choice, selected: 0), true);
    expect(canCheckAnswer(bank), false);
    expect(canCheckAnswer(bank, pickedCount: 1), true);
    expect(canCheckAnswer(typed, typed: '  '), false);
    expect(canCheckAnswer(typed, typed: 'hi'), true);
    expect(canCheckAnswer(listen, typed: 'w'), true);
  });

  test('gradeAnswer per type', () {
    expect(gradeAnswer(choice, selected: 1), true);
    expect(gradeAnswer(choice, selected: 0), false);
    expect(gradeAnswer(bank, pickedWords: ['y', 'x']), true);
    expect(gradeAnswer(bank, pickedWords: ['x', 'y']), false);
    expect(gradeAnswer(typed, typed: 'Hello!'), true); // lenient match
    expect(gradeAnswer(typed, typed: 'nope'), false);
    expect(gradeAnswer(listen, typed: 'water'), true);
  });

  test('correctTextFor and userTextFor per type', () {
    expect(correctTextFor(choice), 'b');
    expect(correctTextFor(bank), 'y x');
    expect(correctTextFor(typed), 'hello');
    expect(userTextFor(choice, selected: 2), 'c');
    expect(userTextFor(choice), '(no answer)');
    expect(userTextFor(bank, pickedWords: ['x']), 'x');
    expect(userTextFor(typed, typed: ' '), '(no answer)');
    expect(userTextFor(listen, typed: 'agua'), 'agua');
  });

  test('explainSuffixFor matches the bundled key format', () {
    expect(explainSuffixFor(choice, selected: 2), '2');
    expect(explainSuffixFor(bank), 'wb');
    expect(explainSuffixFor(typed), 'ty');
    expect(explainSuffixFor(listen), 'ty');
  });
}
