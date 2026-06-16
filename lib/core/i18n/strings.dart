/// Minimal localization layer (charter §0.4): every user-facing string goes
/// through [S.t]. Defaults are the English source of truth and must stay
/// byte-stable so tests prove no regression. Locale/DB overrides arrive in
/// phase 3 (content standardization → DB); keys are immortal, locales INSERT-only.
class S {
  const S._();

  static String t(String key, String fallback) => _overrides[key] ?? fallback;

  static const Map<String, String> _overrides = <String, String>{};
}
