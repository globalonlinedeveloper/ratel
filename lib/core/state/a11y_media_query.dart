import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'app_settings_scope.dart';

/// Applies accessibility settings app-wide via MediaQuery overrides.
/// Sits just below MaterialApp's builder so every route inherits it.
class A11yMediaQuery extends StatelessWidget {
  const A11yMediaQuery({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppSettings s = AppSettingsScope.of(context);
    final MediaQueryData mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(s.textScale),
        // honor the in-app reduce-motion toggle even if the OS flag is off.
        disableAnimations: mq.disableAnimations || s.reduceMotion,
        // surface high-contrast to the platform flag; theme also reads it.
        highContrast: mq.highContrast || s.highContrast,
      ),
      child: child,
    );
  }
}
