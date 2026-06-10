import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around text-to-speech for listening exercises. Configured for
/// clear, slightly-slow English. Every call is guarded so a platform without
/// TTS (or the test VM, where the plugin channel is absent) is a silent no-op
/// rather than a crash.
class Tts {
  Tts._();
  static final Tts instance = Tts._();

  final FlutterTts _t = FlutterTts();
  bool _configured = false;

  Future<void> _ensure() async {
    if (_configured) return;
    _configured = true;
    try {
      await _t.setLanguage('en-US');
      await _t.setSpeechRate(0.45); // slower than default — easier for learners
      await _t.setPitch(1.0);
      await _t.setVolume(1.0);
    } catch (_) {
      // leave _configured true; speak() will also be guarded
    }
  }

  /// Speak [text]. Stops any current utterance first. No-op on failure.
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _ensure();
      await _t.stop();
      await _t.speak(text);
    } catch (_) {
      // TTS unavailable on this platform/runtime — silently ignore.
    }
  }

  Future<void> stop() async {
    try {
      await _t.stop();
    } catch (_) {}
  }
}
