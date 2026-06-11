import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('analytics facade never throws without Firebase', () {
    expect(() {
      Analytics.signUp();
      Analytics.login();
      Analytics.lessonStart('u1l1');
      Analytics.lessonComplete('u1l1', 40, 5, 5);
      Analytics.log('custom', {'a': 1, 'b': null});
    }, returnsNormally);
  });
}
