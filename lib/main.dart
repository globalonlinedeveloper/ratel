import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  if (Config.hasSupabase) {
    await Supabase.initialize(
      url: Config.supabaseUrl,
      publishableKey: Config.supabaseAnonKey,
    );
  }
  await Sfx.instance.load();
  await ExplainStore.instance.load();
  await ContentStore.instance.load();
  runApp(const RatelApp());
}

class RatelApp extends StatelessWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: ratelTheme(),
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
  }
}
