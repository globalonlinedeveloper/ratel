import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'config.dart';
import 'sfx.dart';
import 'screens/auth_gate.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Config.hasSupabase) {
    await Supabase.initialize(
      url: Config.supabaseUrl,
      publishableKey: Config.supabaseAnonKey,
    );
  }
  await Sfx.instance.load();
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
        return _AnimatedBackdrop(
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


/// A subtle, slowly-shifting gradient backdrop behind the app frame.
class _AnimatedBackdrop extends StatefulWidget {
  final Widget child;
  const _AnimatedBackdrop({required this.child});

  @override
  State<_AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<_AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(seconds: 16))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, -1),
              end: Alignment(1, 1 - 2 * t),
              colors: const [Color(0xFFEDEAE0), Color(0xFFE4E8E3), Color(0xFFEBE6DD)],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
