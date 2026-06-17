import 'locales/ta.dart';

/// Minimal localization layer (charter §0.4): every user-facing string goes
/// through [S.t]. The `default` passed to [S.t] is the English source of truth
/// and must stay byte-stable so tests prove no regression.
///
/// Phase-1 i18n: English is the default; a single bundled non-English locale
/// (Tamil, [kStringsTa]) can be switched IN-SESSION via [loadLocale]. Any key
/// not translated for the active locale falls back to its English default
/// (keys are immortal). The full INSERT-only multi-locale set + cross-restart
/// DB-backed overrides land in Phase 3.
class S {
  const S._();

  /// Resolve [key] for the active locale, falling back to [fallback] (the
  /// English source of truth) for any untranslated or unknown key.
  static String t(String key, String fallback) =>
      _active[key] ?? _overrides[key] ?? fallback;

  /// The active locale code ('en' | 'ta'). Defaults to English.
  static String get localeCode => _localeCode;
  static String _localeCode = 'en';

  /// Translations for the active locale; empty for English (everything falls
  /// back to the English defaults).
  static Map<String, String> _active = const <String, String>{};

  /// Phase-3 DB/override slot; intentionally empty in Phase 1.
  static const Map<String, String> _overrides = <String, String>{};

  /// Locale codes that ship a real bundled map this phase, with display names.
  static const Map<String, String> availableLocales = <String, String>{
    'en': 'English',
    'ta': 'தமிழ்',
  };

  /// Switch the active locale. Unknown codes fall back to English.
  static void loadLocale(String code) {
    _localeCode = availableLocales.containsKey(code) ? code : 'en';
    _active = switch (_localeCode) {
      'ta' => kStringsTa,
      _ => const <String, String>{},
    };
  }
}
