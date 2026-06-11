import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// Guest-mode helpers. An anonymous session has full app access; converting
/// via [saveGuestAccount] keeps the SAME user id, so every bit of progress
/// (XP, streak, friends, attempts) carries over with zero migration.
bool get isGuest {
  if (!Config.hasSupabase) return false;
  try {
    return Supabase.instance.client.auth.currentUser?.isAnonymous ?? false;
  } catch (_) {
    return false;
  }
}

Future<void> startGuestSession() async {
  await Supabase.instance.client.auth.signInAnonymously();
}

/// Attach email+password (and optionally a name) to the anonymous user.
Future<void> saveGuestAccount(
    {required String email, required String password, String? name}) async {
  final auth = Supabase.instance.client.auth;
  await auth.updateUser(UserAttributes(
    email: email,
    password: password,
    data: (name == null || name.isEmpty) ? null : {'full_name': name},
  ));
  if (name != null && name.isNotEmpty) {
    final uid = auth.currentUser?.id;
    if (uid != null) {
      await Supabase.instance.client
          .from('profiles')
          .update({'display_name': name}).eq('id', uid);
    }
  }
}
