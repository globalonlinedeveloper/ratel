import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/state/app_settings.dart';
import 'core/state/app_settings_scope.dart';
import 'core/theme/theme.dart';
import 'core/widgets/mobile_frame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(RatelApp(settings: AppSettings(prefs)));
}

class RatelApp extends StatelessWidget {
  const RatelApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: settings,
      child: AnimatedBuilder(
        animation: settings,
        builder: (_, _) => MaterialApp.router(
          title: 'Ratel',
          debugShowCheckedModeBanner: false,
          theme: ratelTheme(accentIndex: settings.accentIndex),
          darkTheme: ratelDarkTheme(accentIndex: settings.accentIndex),
          themeMode: settings.themeMode,
          routerConfig: appRouter,
          builder: (BuildContext context, Widget? child) =>
              MobileFrame(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
