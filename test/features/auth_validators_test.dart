import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/auth/validators.dart';

void main() {
  group('validateEmail', () {
    test('valid', () => expect(validateEmail('a@b.com'), isNull));
    test('empty', () => expect(validateEmail('  '), 'Enter your email'));
    test('bad format', () => expect(validateEmail('nope'), 'Enter a valid email'));
  });

  group('validatePassword', () {
    test('valid 8+', () => expect(validatePassword('abcd1234'), isNull));
    test('empty', () => expect(validatePassword(''), 'Enter a password'));
    test('too short', () => expect(validatePassword('abc'), 'Use at least 8 characters'));
  });

  group('validateConfirm', () {
    test('match', () => expect(validateConfirm('abcd1234', 'abcd1234'), isNull));
    test('mismatch', () => expect(validateConfirm('abcd1234', 'nope'), "Passwords don't match"));
  });

  group('validateName', () {
    test('valid', () => expect(validateName('Sam'), isNull));
    test('empty', () => expect(validateName('   '), 'Enter your name'));
  });

  group('validatePhone', () {
    test('valid 10 digits', () => expect(validatePhone('+1 415 555 9000'), isNull));
    test('too short', () => expect(validatePhone('12345'), 'Enter a valid phone number'));
    test('too long', () => expect(validatePhone('1234567890123456'), 'Enter a valid phone number'));
  });

  group('isOtpComplete', () {
    test('6 digits', () => expect(isOtpComplete('123456'), isTrue));
    test('5 digits', () => expect(isOtpComplete('12345'), isFalse));
    test('non-numeric', () => expect(isOtpComplete('12345a'), isFalse));
  });

  group('passwordStrength', () {
    test('0 empty', () => expect(passwordStrength(''), 0));
    test('1 letters-only 8', () => expect(passwordStrength('abcdefgh'), 1));
    test('2 letter+digit 8', () => expect(passwordStrength('abcd1234'), 2));
    test('3 letter+digit 12', () => expect(passwordStrength('abcdef123456'), 3));
  });
}
