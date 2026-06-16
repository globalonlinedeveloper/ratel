import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ratel/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dark theme is dark and keeps the brand accents', () {
    final dark = ratelDarkTheme();
    expect(dark.brightness, Brightness.dark);
    expect(dark.colorScheme.primary, RatelColorsDark.teal);
    expect(dark.colorScheme.secondary, RatelColorsDark.honey);
    expect(ratelTheme().brightness, Brightness.light);
  });

  test('theme mode persists via shared_preferences', () async {
    SharedPreferences.setMockInitialValues({});
    await setThemeMode(ThemeMode.dark);
    expect(themeModeNotifier.value, ThemeMode.dark);
    themeModeNotifier.value = ThemeMode.system; // forget in memory
    await loadThemeMode(); // reload from storage
    expect(themeModeNotifier.value, ThemeMode.dark);
    await setThemeMode(ThemeMode.system);
  });

  testWidgets('context colors flip between themes', (tester) async {
    late Color light;
    late Color dark;
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelTheme(),
        home: Builder(
          builder: (c) {
            light = c.surfaceC;
            return const SizedBox();
          },
        ),
      ),
    );
    // Fresh tree first: MaterialApp animates theme changes, so pumping the
    // dark app over the light one would capture the lerp's first (light) frame.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      MaterialApp(
        theme: ratelDarkTheme(),
        home: Builder(
          builder: (c) {
            dark = c.surfaceC;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(light, isNot(equals(dark)));
    expect(dark, RatelColorsDark.surface);
  });
}
