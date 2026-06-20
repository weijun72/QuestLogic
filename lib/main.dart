import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gwffhhaupuqjnvbyqxfk.supabase.co',
    publishableKey: 'sb_publishable_yoBPRKJi921JPagoPP9WPA_Ke6r8K0_',
  );

  runApp(const QuestLogicApp());
}

class QuestLogicApp extends StatelessWidget {
  const QuestLogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuestLogic',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6b5a48)),
        scaffoldBackgroundColor: const Color(0xFFfff4e9),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.session != null) {
          return const MainScreen();
        }
        return const AuthScreen();
      },
    );
  }
}
