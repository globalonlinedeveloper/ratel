import 'package:firebase_analytics/firebase_analytics.dart';

/// Device (Android/iOS) analytics via Firebase Analytics. Crash-safe:
/// if Firebase failed to init (tests, desktop), every call no-ops.
void logEvent(String name, Map<String, Object?> params) {
  try {
    final clean = <String, Object>{
      for (final e in params.entries)
        if (e.value != null) e.key: e.value!,
    };
    FirebaseAnalytics.instance.logEvent(name: name, parameters: clean);
  } catch (_) {
    // No Firebase here (VM tests / desktop) — analytics is best-effort.
  }
}
