import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Lightweight sound + haptic feedback for the lesson flow.
///
/// Every call is fire-and-forget and wrapped in try/catch, so a missing
/// asset, a missing codec, or a browser autoplay restriction can never
/// crash a lesson. Sounds can be muted globally via [enabled]; haptics
/// are a silent no-op on platforms that don't support them (web/desktop).
class Sfx {
  Sfx._();
  static final Sfx instance = Sfx._();

  /// Master toggle for sound effects (haptics stay independent).
  bool enabled = true;

  final AudioPlayer _correct = AudioPlayer(playerId: 'sfx_correct');
  final AudioPlayer _wrong = AudioPlayer(playerId: 'sfx_wrong');
  final AudioPlayer _complete = AudioPlayer(playerId: 'sfx_complete');

  Future<void> _play(AudioPlayer player, String asset, double volume) async {
    if (!enabled) return;
    try {
      await player.stop();
      await player.setVolume(volume);
      await player.play(AssetSource(asset));
    } catch (_) {
      // Ignore playback errors (web autoplay policy, missing codec, etc.).
    }
  }

  /// Correct answer: cheerful rising chime + a medium tap.
  void correct() {
    _play(_correct, 'audio/correct.wav', 0.7);
    _haptic(HapticFeedback.mediumImpact);
  }

  /// Wrong answer: soft low buzz + a firmer tap.
  void wrong() {
    _play(_wrong, 'audio/wrong.wav', 0.6);
    _haptic(HapticFeedback.heavyImpact);
  }

  /// Lesson complete: level-up sting + a celebratory tap.
  void complete() {
    _play(_complete, 'audio/complete.mp3', 0.85);
    _haptic(HapticFeedback.heavyImpact);
  }

  /// Light selection tick when tapping an option.
  void tap() => _haptic(HapticFeedback.selectionClick);

  void _haptic(Future<void> Function() fn) {
    try {
      fn();
    } catch (_) {
      // Haptics unsupported on this platform — ignore.
    }
  }
}
