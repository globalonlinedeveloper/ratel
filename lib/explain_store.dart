import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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
  }

  /// Synchronous lookup; null if not loaded or no entry for [key].
  String? lookup(String key) => _map?[key];
}
