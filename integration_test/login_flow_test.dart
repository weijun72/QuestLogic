import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quest_logic/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow', () {
    testWidgets('user can see login screen on launch', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Sign out after app initializes, then wait for auth screen
      await Supabase.instance.client.auth.signOut();
      await tester.pumpAndSettle();

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('user can type email and password', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      await Supabase.instance.client.auth.signOut();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.pumpAndSettle();

      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}
