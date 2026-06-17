import '../../core/i18n/strings.dart';

/// Pure form-validation helpers — format/length checks only, NO backend
/// (they do not verify accounts exist). Return null when valid (Flutter
/// validator convention), else an `S.t` message. One source of truth for the
/// auth screens; unit-tested without pumping widgets.

String? validateEmail(String v) {
  final String s = v.trim();
  if (s.isEmpty) return S.t('val_email_required', 'Enter your email');
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
    return S.t('val_email_invalid', 'Enter a valid email');
  }
  return null;
}

String? validatePassword(String v) {
  if (v.isEmpty) return S.t('val_pw_required', 'Enter a password');
  if (v.length < 8) return S.t('val_pw_short', 'Use at least 8 characters');
  return null;
}

String? validateConfirm(String pw, String confirm) {
  if (confirm != pw) return S.t('val_pw_mismatch', "Passwords don't match");
  return null;
}

String? validateName(String v) {
  if (v.trim().isEmpty) return S.t('val_name_required', 'Enter your name');
  return null;
}

String? validatePhone(String v) {
  final String digits = v.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 7 || digits.length > 15) {
    return S.t('val_phone_invalid', 'Enter a valid phone number');
  }
  return null;
}

bool isOtpComplete(String code) =>
    code.length == 6 && int.tryParse(code) != null;

/// 0–3 strength for the meter: 0 empty; +1 len>=8; +1 len>=12; +1 letter+digit.
int passwordStrength(String v) {
  if (v.isEmpty) return 0;
  int s = 0;
  if (v.length >= 8) s++;
  if (v.length >= 12) s++;
  if (RegExp(r'[A-Za-z]').hasMatch(v) && RegExp(r'\d').hasMatch(v)) s++;
  return s;
}
