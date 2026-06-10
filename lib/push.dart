import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// FCM client: asks permission at a warm moment (first lesson complete),
/// stores the token on the profile, keeps it fresh on later launches.
/// Server side: the send-push Edge Function (FCM HTTP v1) reads tokens
/// from profiles.fcm_token.
class Push {
  Push._();
  static final Push instance = Push._();

  bool get _usable => !kIsWeb && Config.hasSupabase;

  /// One-time ask, gated by the caller at a positive moment.
  Future<void> requestOnce() async {
    if (!_usable) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('push_asked') ?? false) return;
      await prefs.setBool('push_asked', true);
      final settings =
          await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        await _saveToken();
      }
    } catch (_) {}
  }

  /// Refresh the stored token when permission was already granted.
  Future<void> refreshIfGranted() async {
    if (!_usable) return;
    try {
      final s =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (s.authorizationStatus == AuthorizationStatus.authorized) {
        await _saveToken();
      }
      FirebaseMessaging.instance.onTokenRefresh
          .listen((_) => _saveToken());
    } catch (_) {}
  }

  Future<void> _saveToken() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await client.from('profiles')
          .update({'fcm_token': token}).eq('id', uid);
    } catch (_) {}
  }
}
