import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/state/a11y_media_query.dart';
import 'package:ratel/core/state/app_settings.dart';
import 'package:ratel/core/state/app_settings_scope.dart';

import '../support/settings_harness.dart';

void main() {
  testWidgets('A11yMediaQuery applies textScale + reduceMotion to MediaQuery',
      (tester) async {
    final AppSettings settings = await makeTestSettings();
    settings.setTextScale(1.5);
    settings.setReduceMotion(true);
    late BuildContext probe;
    await tester.pumpWidget(
      AppSettingsScope(
        settings: settings,
        child: MaterialApp(
          home: A11yMediaQuery(
            child: Builder(builder: (BuildContext c) {
              probe = c;
              return const SizedBox();
            }),
          ),
        ),
      ),
    );
    final MediaQueryData mq = MediaQuery.of(probe);
    expect(mq.textScaler.scale(10), 15);
    expect(mq.disableAnimations, isTrue);
    expect(mq.highContrast, isFalse);
  });
}
