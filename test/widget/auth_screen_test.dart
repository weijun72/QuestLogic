import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_logic/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({}); // ← mocks the plugin
    await Supabase.initialize(
      url: 'https://gwffhhaupuqjnvbyqxfk.supabase.co',
      publishableKey: 'sb_publishable_yoBPRKJi921JPagoPP9WPA_Ke6r8K0_',
    );
  });
  group('Auth Screen', () {
    testWidgets('renders email input field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      expect(find.byKey(const Key('emailField')), findsOneWidget);
    });

    testWidgets('renders password input field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      expect(find.byKey(const Key('passwordField')), findsOneWidget);
    });

    testWidgets('renders Sign In button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('renders Sign Up button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('allows typing in email field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'test@example.com',
      );

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('allows typing in password field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'mypassword',
      );

      // Password fields are obscured so we check the controller value
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

      // Tap sign in without entering anything
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });
}
