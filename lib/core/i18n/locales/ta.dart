/// Tamil (ta) UI strings — the first bundled non-English locale (Phase 1).
///
/// Keys mirror [S.t] keys; any key NOT present here falls back to the English
/// source-of-truth default passed to `S.t(key, default)`. This is a deliberate
/// starter subset (navigation, settings, appearance, a few high-traffic
/// titles) that proves the i18n pipeline end-to-end. The full INSERT-only
/// multi-locale set is a Phase-3 DB concern — do not claim "44+ locales" in UI.
const Map<String, String> kStringsTa = <String, String>{
  // bottom navigation (screen-reader tooltips)
  'nav_home': 'முகப்பு',
  'nav_practice': 'பயிற்சி',
  'nav_leagues': 'லீக்குகள்',
  'nav_profile': 'சுயவிவரம்',
  // shared a11y
  'a11y_back': 'பின்',
  // settings hub
  'settings_title': 'அமைப்புகள்',
  'settings_appearance': 'தோற்றம் & மொழி',
  'settings_account': 'கணக்கு',
  'settings_audio': 'ஒலி',
  'settings_learning': 'கற்றல்',
  'settings_notif': 'அறிவிப்புகள்',
  'settings_privacy': 'தனியுரிமை & தரவு',
  'settings_widgets': 'விட்ஜெட்டுகள்',
  // appearance & language screen
  'appear_title': 'தோற்றம் & மொழி',
  'appear_lang': 'செயலி மொழி',
  'appear_lang_en': 'ஆங்கிலம்',
  'appear_lang_ta': 'தமிழ்',
  'appear_lang_note': 'செயலி மொழியை உடனே மாற்றவும். மேலும் மொழிகள் பின்னர் வரும்.',
  'appear_theme': 'தீம்',
  'appear_light': 'ஒளி',
  'appear_dark': 'இருள்',
  'appear_system': 'சாதனம்',
  'appear_motion': 'அசைவைக் குறை',
  'appear_accent': 'சிறப்பு நிறம்',
  // high-traffic titles
  'practice_title': 'பயிற்சி',
  'profile_edit': 'சுயவிவரத்தைத் திருத்து',
  'ob_lang_welcome': 'Ratel-க்கு வரவேற்கிறோம்',
  'ob_lang_cta': 'தொடரவும்',
};
