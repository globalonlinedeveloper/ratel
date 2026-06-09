import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Tracks the current correct-answer streak and maps it onto the 5-step
/// rising "correct" pitch ladder (then caps). Pure logic — unit-tested.
class ComboCounter {
  int value = 0;

  /// Returns the ladder index to play (0..maxStep), then advances the combo.
  int onCorrect({int maxStep = 4}) {
    final step = value.clamp(0, maxStep);
    value++;
    return step;
  }

  void onWrong() => value = 0;
  void reset() => value = 0;
}

/// Coordinated sound + haptic feedback for the lesson flow. Every call is
/// fire-and-forget and wrapped in try/catch, so a missing asset, missing
/// codec, or browser autoplay restriction can never crash a lesson.
class Sfx {
  Sfx._();
  static final Sfx instance = Sfx._();

  /// Toggles (persistence + UI added in a later increment).
  bool soundOn = true;
  bool hapticsOn = true;

  final ComboCounter combo = ComboCounter();

  final AudioPlayer _answer = AudioPlayer(playerId: 'sfx_answer');
  final AudioPlayer _ui = AudioPlayer(playerId: 'sfx_ui');
  final AudioPlayer _fanfare = AudioPlayer(playerId: 'sfx_fanfare');

  Future<void> _play(AudioPlayer p, String asset, double vol) async {
    if (!soundOn) return;
    try {
      await p.stop();
      await p.setVolume(vol);
      await p.play(AssetSource(asset));
    } catch (_) {}
  }

  void _hap(Future<void> Function() fn) {
    if (!hapticsOn) return;
    try {
      fn();
    } catch (_) {}
  }

  /// Correct: the next rising rung of the pitch ladder + a medium tap.
  void correct() {
    final step = combo.onCorrect();
    _play(_answer, 'audio/correct_$step.wav', 0.7);
    _hap(HapticFeedback.mediumImpact);
  }

  /// Wrong: a soft, low, non-punishing tone; resets the combo.
  void wrong() {
    combo.onWrong();
    _play(_answer, 'audio/wrong.wav', 0.6);
    _hap(HapticFeedback.heavyImpact);
  }

  /// Lesson complete: the resolving fanfare + a celebratory tap.
  void complete() {
    combo.reset();
    _play(_fanfare, 'audio/complete.wav', 0.85);
    _hap(HapticFeedback.heavyImpact);
  }

  /// Subtle tick when selecting an option.
  void tap() {
    _play(_ui, 'audio/tap.wav', 0.3);
    _hap(HapticFeedback.selectionClick);
  }

  /// A short sparkle for streak milestones.
  void streak() {
    _play(_ui, 'audio/streak.wav', 0.6);
    _hap(HapticFeedback.mediumImpact);
  }

  /// Reset the combo at the start of a lesson.
  void resetCombo() => combo.reset();
}
