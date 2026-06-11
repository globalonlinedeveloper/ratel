import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'flags.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'strings.dart';
import 'milestones.dart';
import 'push.dart';
import 'theme.dart';
import 'config.dart';
import 'sfx.dart';
import 'explain_store.dart';
import 'content_store.dart';
import 'screens/auth_gate.dart';
import 'screens/home_screen.dart';
import 'widgets/aurora_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    // Crash reporting (Android/iOS; config from google-services.json).
    try {
      await Firebase.initializeApp();
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance
            .recordError(error, stack, fatal: true);
        return true;
      };
    } catch (_) {
      // Never block startup on telemetry.
    }
  }
  if (Config.hasSupabase) {
    await Supabase.initialize(
      url: Config.supabaseUrl,
      publishableKey: Config.supabaseAnonKey,
    );
  }
  await Sfx.instance.load();
  await loadThemeMode();
  await loadReduceMotion();
  await Flags.instance.load(); // remote config before dependent loads
  await S.instance.load(); // server copy (in-code defaults if offline)
  await S.instance.restoreLocale();
  // share-link friend code (web): stow now, redeem after sign-in
  try {
    final code = friendCodeFromUri(Uri.base);
    if (code != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_friend_code', code);
    }
  } catch (_) {}
  await loadBattleMode();
  await ExplainStore.instance.load();
  await ContentStore.instance.load();
  Push.instance.refreshIfGranted(); // fire-and-forget token upkeep
  runApp(const RatelApp());
}

class RatelApp extends StatelessWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) {
          return MaterialApp(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: ratelTheme(),
      darkTheme: ratelDarkTheme(),
      themeMode: mode,
      builder: (context, child) {
        // Phone-width frame, centered on a slowly-shifting gradient backdrop.
        return AuroraBackground(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      // With config present, require login; otherwise run straight to Home.
      home: Config.hasSupabase ? const AuthGate() : const HomeScreen(),
          );
        });
  }
}
