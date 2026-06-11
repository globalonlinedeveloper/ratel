import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'strings.dart';

/// Loads the pre-authored answer explanations bundled at
/// `assets/explanations.json` and serves them by key. These are generated
/// deterministically from the lesson content (see `tool/gen_explanations.py`) —
/// no network, no API, no cost at runtime. Keys:
///   choice:   `lessonId:exerciseIndex:chosenOptionIndex`
///   wordBank: `lessonId:exerciseIndex:wb`
class ExplainStore {
  ExplainStore._();
  static final ExplainStore instance = ExplainStore._();

  Map<String, String>? _map;
  Map<String, String>? _ta;
  bool get isLoaded => _map != null;

  Future<void> load() async {
    if (_map != null) return;
    try {
      final raw = await rootBundle.loadString('assets/explanations.json');
      final m = json.decode(raw) as Map<String, dynamic>;
      _map = m.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      _map = {}; // never crash a lesson over a missing asset
    }
    try {
      final raw =
          await rootBundle.loadString('assets/explanations_ta.json');
      final m = json.decode(raw) as Map<String, dynamic>;
      _ta = m.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      _ta = {}; // Tamil twin optional; en always carries
    }
  }

  /// Synchronous lookup honoring the app locale: Tamil first when
  /// S.locale == 'ta', English fallback, null when unknown.
  String? lookup(String key) {
    if (S.instance.locale == 'ta') {
      final t = _ta?[key];
      if (t != null && t.isNotEmpty) return t;
    }
    return _map?[key];
  }

  /// Test injection for the Tamil twin.
  void debugSetTa(Map<String, String> m) => _ta = m;
  void debugSetEn(Map<String, String> m) => _map = m;
}
