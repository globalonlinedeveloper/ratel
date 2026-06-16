import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'core/widgets/mobile_frame.dart';

void main() => runApp(const RatelApp());

class RatelApp extends StatelessWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: ratelTheme(),
      darkTheme: ratelDarkTheme(),
      routerConfig: appRouter,
      builder: (BuildContext context, Widget? child) =>
          MobileFrame(child: child ?? const SizedBox.shrink()),
    );
  }
}
