import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../styles.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        emailRedirectTo: 'questlogic://',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email for the confirmation link!'),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppScaffold.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Container(
                height: 250,
                alignment: Alignment.center,
                child: Image.network(
                  'https://www.image2url.com/r2/default/images/1781540424467-80882267-2567-45ff-912d-7930c02f9976.png',
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Email', style: AppText.label),
              const SizedBox(height: 6),
              TextField(
                key: const Key('emailField'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                decoration: AppDecor.outlinedField.copyWith(
                  hintText: 'email@address.com',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text('Password', style: AppText.label),
              const SizedBox(height: 6),
              TextField(
                key: const Key('passwordField'),
                controller: _passwordController,
                obscureText: true,
                textCapitalization: TextCapitalization.none,
                decoration: AppDecor.outlinedField.copyWith(
                  hintText: 'Password',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _loading ? null : _signIn,
                style: AppDecor.primaryButton(),
                child: const Text('Sign in', style: AppText.buttonLabel),
              ),
              const SizedBox(height: AppSpacing.xs),
              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                style: AppDecor.secondaryButton(),
                child: const Text('Sign up', style: AppText.buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
