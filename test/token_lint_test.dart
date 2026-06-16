import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Charter §0.3 / §4: no raw hex Color(0x..) in feature or component code —
/// the design tokens (core/theme) are the only allowed source. Grows
/// automatically as features land.
void main() {
  test('no raw hex Color(0x..) in features/ or design_system/', () {
    final dirs = <String>['lib/features', 'lib/design_system'];
    final hex = RegExp(r'Color\(0x');
    final offenders = <String>[];
    for (final d in dirs) {
      final dir = Directory(d);
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (hex.hasMatch(lines[i])) {
            offenders.add('${entity.path}:${i + 1}  ${lines[i].trim()}');
          }
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'Use theme tokens, not raw hex:\n${offenders.join('\n')}');
  });
}
