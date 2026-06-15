import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/models.dart';
import 'package:ratel/exercise_audio.dart';

void main() {
  group('audioStimulus answer-safety (Phase 2.1)', () {
    test('choice with a sentence is hearable, blanks normalized', () {
      const ex = Exercise.choice(
          prompt: 'Pick', sentence: 'I ___ happy', options: ['am', 'is'],
          correctIndex: 0);
      final s = audioStimulus(ex);
      expect(s, isNotNull);
      expect(s, isNot(contains('_')));
    });
    test('typed with a sentence is hearable', () {
      const ex = Exercise.typed(
          prompt: 'Type', sentence: 'Say hello', accepted: ['hello']);
      expect(audioStimulus(ex), isNotNull);
    });
    test('chat npc line is hearable', () {
      const ex = Exercise.chat(
          prompt: 'Reply', npcLine: 'How are you?', accepted: ['fine']);
      expect(audioStimulus(ex), 'How are you?');
    });
    test('wordBank never reveals the target', () {
      const ex = Exercise.wordBank(
          prompt: 'Build', options: ['I', 'am', 'happy'],
          correctOrder: ['I', 'am', 'happy']);
      expect(audioStimulus(ex), isNull);
    });
    test('dialogueOrder never reveals the order', () {
      const ex = Exercise.dialogueOrder(
          prompt: 'Order', lines: ['Hi', 'Bye'], correctOrder: ['Hi', 'Bye']);
      expect(audioStimulus(ex), isNull);
    });
    test('multiBlank template is not spoken', () {
      const ex = Exercise.multiBlank(
          prompt: 'Fill', template: 'I ___ ___', options: ['am', 'here'],
          answers: ['am', 'here']);
      expect(audioStimulus(ex), isNull);
    });
    test('matchPairs has no single stimulus', () {
      const ex = Exercise.matchPairs(
          prompt: 'Match', left: ['a'], right: ['b']);
      expect(audioStimulus(ex), isNull);
    });
    test('listen types own their player', () {
      const l = Exercise.listen(prompt: 'Hear', accepted: ['hi']);
      const lr = Exercise.listenRespond(
          prompt: 'Hear', say: 'hi', options: ['a', 'b'], correctIndex: 0);
      expect(audioStimulus(l), isNull);
      expect(audioStimulus(lr), isNull);
    });
    test('spokenText collapses whitespace and underscores', () {
      expect(spokenText('I    ___   go'), 'I … go');
    });
  });
}
