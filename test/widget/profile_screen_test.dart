import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quest_logic/screens/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({}); // ← mocks the plugin
    // Initialize Supabase before any tests run
    await Supabase.initialize(
      url: 'https://gwffhhaupuqjnvbyqxfk.supabase.co',
      publishableKey: 'sb_publishable_yoBPRKJi921JPagoPP9WPA_Ke6r8K0_',
    );
  });
  group('Profile Screen', () {
    testWidgets('renders username label', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('renders bio label', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

      expect(find.text('Bio'), findsOneWidget);
    });

    testWidgets('renders Update button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pump();

      // Button exists in either loading or loaded state
      final hasUpdate = find.text('Update').evaluate().isNotEmpty;
      final hasLoading = find.text('Loading ...').evaluate().isNotEmpty;
      expect(hasUpdate || hasLoading, true);
    });

    testWidgets('renders Sign Out button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Sign Out'), findsOneWidget);
    });
  });
}
