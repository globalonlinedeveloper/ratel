import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'core/theme/tokens.dart';

void main() => runApp(const RatelApp());

class RatelApp extends StatelessWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: ratelTheme(),
      darkTheme: ratelDarkTheme(),
      home: const RatelLanding(),
    );
  }
}

/// Temporary landing — proves the design system renders. Replaced by the
/// router + Login screen in the app-shell increment.
class RatelLanding extends StatelessWidget {
  const RatelLanding({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(RatelSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ratel',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: tk.primary,
                  ),
                ),
                const SizedBox(height: RatelSpacing.sm),
                Text(
                  'Greenfield · design system online',
                  style: TextStyle(color: context.mutedC),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
