import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../i18n/strings.dart';

/// App-wide, persisted user settings (theme, accent, accessibility).
/// Charter §1: lightest viable state — a single ChangeNotifier, no new state dep.
/// Lives in core/ (token-lint exempt); references token *names* only, no raw hex.
class AppSettings extends ChangeNotifier {
  AppSettings(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;

  // ---- persisted keys (immortal; never rename) ----
  static const String kThemeMode = 'settings.themeMode'; // 'light'|'dark'|'system'
  static const String kAccentIndex = 'settings.accentIndex'; // 0..2
  static const String kTextScale = 'settings.textScale'; // double 0.85..1.6
  static const String kContrast = 'settings.highContrast'; // bool
  static const String kReduceMotion = 'settings.reduceMotion'; // bool
  static const String kDyslexia = 'settings.dyslexiaFont'; // bool
  static const String kCaptions = 'settings.captions'; // bool
  static const String kNoTime = 'settings.noTimePressure'; // bool
  static const String kLocale = 'settings.localeCode'; // 'en'|'ta' (Phase-1 bundled)

  // ---- defaults (owner-confirmed 2026-06-17: contrast OFF, motion OFF, captions ON) ----
  ThemeMode _themeMode = ThemeMode.system;
  int _accentIndex = 0;
  double _textScale = 1.0; // slider maps 0.85..1.6; default 1.0 (=neutral)
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _dyslexiaFont = false;
  bool _captions = true;
  bool _noTimePressure = false;
  String _localeCode = 'en';

  ThemeMode get themeMode => _themeMode;
  int get accentIndex => _accentIndex;
  double get textScale => _textScale;
  bool get highContrast => _highContrast;
  bool get reduceMotion => _reduceMotion;
  bool get dyslexiaFont => _dyslexiaFont;
  bool get captions => _captions;
  bool get noTimePressure => _noTimePressure;
  String get localeCode => _localeCode;

  void _load() {
    final String? tm = _prefs.getString(kThemeMode);
    _themeMode = switch (tm) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _accentIndex = _prefs.getInt(kAccentIndex) ?? _accentIndex;
    _textScale = _prefs.getDouble(kTextScale) ?? _textScale;
    _highContrast = _prefs.getBool(kContrast) ?? _highContrast;
    _reduceMotion = _prefs.getBool(kReduceMotion) ?? _reduceMotion;
    _dyslexiaFont = _prefs.getBool(kDyslexia) ?? _dyslexiaFont;
    _captions = _prefs.getBool(kCaptions) ?? _captions;
    _noTimePressure = _prefs.getBool(kNoTime) ?? _noTimePressure;
    _localeCode = _prefs.getString(kLocale) ?? _localeCode;
    S.loadLocale(_localeCode);
    // no notifyListeners(): _load runs in ctor before any listener attaches.
  }

  // ---- setters: mutate -> persist -> notify ----
  void setThemeMode(ThemeMode m) {
    if (m == _themeMode) return;
    _themeMode = m;
    _prefs.setString(kThemeMode, switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
    notifyListeners();
  }

  void setAccentIndex(int i) {
    if (i == _accentIndex) return;
    _accentIndex = i;
    _prefs.setInt(kAccentIndex, i);
    notifyListeners();
  }

  void setTextScale(double v) {
    if (v == _textScale) return;
    _textScale = v;
    _prefs.setDouble(kTextScale, v);
    notifyListeners();
  }

  void setHighContrast(bool v) {
    if (v == _highContrast) return;
    _highContrast = v;
    _prefs.setBool(kContrast, v);
    notifyListeners();
  }

  void setReduceMotion(bool v) {
    if (v == _reduceMotion) return;
    _reduceMotion = v;
    _prefs.setBool(kReduceMotion, v);
    notifyListeners();
  }

  void setDyslexiaFont(bool v) {
    if (v == _dyslexiaFont) return;
    _dyslexiaFont = v;
    _prefs.setBool(kDyslexia, v);
    notifyListeners();
  }

  void setCaptions(bool v) {
    if (v == _captions) return;
    _captions = v;
    _prefs.setBool(kCaptions, v);
    notifyListeners();
  }

  void setNoTimePressure(bool v) {
    if (v == _noTimePressure) return;
    _noTimePressure = v;
    _prefs.setBool(kNoTime, v);
    notifyListeners();
  }

  void setLocaleCode(String code) {
    if (code == _localeCode) return;
    _localeCode = code;
    _prefs.setString(kLocale, code);
    S.loadLocale(code);
    notifyListeners();
  }
}
