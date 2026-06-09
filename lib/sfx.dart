import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Toggles (persisted; surfaced in the Profile settings).
  bool soundOn = true;
  bool hapticsOn = true;
  bool musicOn = false; // ambient music is opt-in (off by default)

  final ComboCounter combo = ComboCounter();

  final AudioPlayer _answer = AudioPlayer(playerId: 'sfx_answer');
  final AudioPlayer _ui = AudioPlayer(playerId: 'sfx_ui');
  final AudioPlayer _fanfare = AudioPlayer(playerId: 'sfx_fanfare');
  final AudioPlayer _music = AudioPlayer(playerId: 'sfx_music');

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

  /// Fire a haptic after [ms] milliseconds (used for choreographed ramps).
  void _hapDelayed(Future<void> Function() fn, int ms) {
    if (!hapticsOn) return;
    Future<void>.delayed(Duration(milliseconds: ms), () => _hap(fn));
  }

  /// Correct: the next rising rung of the pitch ladder + a haptic whose
  /// strength escalates with the combo, double-tapping at the top rung.
  void correct() {
    final step = combo.onCorrect();
    _play(_answer, 'audio/correct_$step.wav', 0.7);
    _comboHaptic(step);
  }

  /// Haptic choreography for a correct answer: light early in a streak,
  /// firmer as it climbs, with a celebratory double-tap once it maxes out.
  void _comboHaptic(int step) {
    if (step >= 4) {
      _hap(HapticFeedback.heavyImpact);
      _hapDelayed(HapticFeedback.lightImpact, 90);
    } else if (step >= 2) {
      _hap(HapticFeedback.mediumImpact);
    } else {
      _hap(HapticFeedback.lightImpact);
    }
  }

  /// Wrong: a soft, low, non-punishing tone; resets the combo.
  void wrong() {
    combo.onWrong();
    _play(_answer, 'audio/wrong.wav', 0.6);
    _hap(HapticFeedback.heavyImpact);
  }

  /// Lesson complete: the resolving fanfare + a two-stage haptic ramp
  /// (medium, then heavy) timed to land with the fanfare's resolution.
  void complete() {
    combo.reset();
    _play(_fanfare, 'audio/complete.wav', 0.85);
    _hap(HapticFeedback.mediumImpact);
    _hapDelayed(HapticFeedback.heavyImpact, 160);
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

  /// Load persisted sound/haptics preferences (call once at startup).
  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      soundOn = p.getBool('sound_on') ?? true;
      hapticsOn = p.getBool('haptics_on') ?? true;
      musicOn = p.getBool('music_on') ?? false;
      if (musicOn) _startMusic();
    } catch (_) {}
  }

  /// Lazily begins the looping ambient bed (fetched on demand, not at boot).
  Future<void> _startMusic() async {
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.22);
      await _music.play(AssetSource('audio/ambient.mp3'));
    } catch (_) {}
  }

  Future<void> setMusicOn(bool v) async {
    musicOn = v;
    try {
      (await SharedPreferences.getInstance()).setBool('music_on', v);
      if (v) {
        await _startMusic();
      } else {
        await _music.stop();
      }
    } catch (_) {}
  }

  Future<void> setSoundOn(bool v) async {
    soundOn = v;
    try {
      (await SharedPreferences.getInstance()).setBool('sound_on', v);
    } catch (_) {}
  }

  Future<void> setHapticsOn(bool v) async {
    hapticsOn = v;
    try {
      (await SharedPreferences.getInstance()).setBool('haptics_on', v);
    } catch (_) {}
  }
}
