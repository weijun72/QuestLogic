import 'package:flutter_test/flutter_test.dart';

// Helper functions to test
bool isValidEmail(String email) {
  return email.contains('@') && email.contains('.');
}

bool isValidPassword(String password) {
  return password.length >= 6;
}

void main() {
  group('Email Validation', () {
    test('accepts a valid email', () {
      expect(isValidEmail('test@example.com'), true);
    });

    test('rejects email without @', () {
      expect(isValidEmail('testexample.com'), false);
    });

    test('rejects empty email', () {
      expect(isValidEmail(''), false);
    });
  });

  group('Password Validation', () {
    test('accepts password with 6 or more characters', () {
      expect(isValidPassword('password123'), true);
    });

    test('rejects password shorter than 6 characters', () {
      expect(isValidPassword('123'), false);
    });

    test('rejects empty password', () {
      expect(isValidPassword(''), false);
    });
  });
}
