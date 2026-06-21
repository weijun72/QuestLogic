import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../styles.dart';
import 'widgets/avatar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsToTeachController = TextEditingController();
  final _skillsToLearnController = TextEditingController();
  bool _loading = true;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _skillsToTeachController.dispose();
    _skillsToLearnController.dispose();
    super.dispose();
  }

  Future<void> _getProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('username, bio, skillsToTeach, skillsToLearn, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _skillsToTeachController.text = data['skillsToTeach'] ?? '';
          _skillsToLearnController.text = data['skillsToLearn'] ?? '';
          _avatarUrl = data['avatar_url'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile({String? newAvatarUrl}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _loading = true);
    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'username': _usernameController.text,
        'bio': _bioController.text,
        'skillsToTeach': _skillsToTeachController.text,
        'skillsToLearn': _skillsToLearnController.text,
        'avatar_url': newAvatarUrl ?? _avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (newAvatarUrl != null && mounted) {
        setState(() => _avatarUrl = newAvatarUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppScaffold.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              AvatarWidget(
                size: 200,
                url: _avatarUrl.isEmpty ? null : _avatarUrl,
                onUpload: (url) => _updateProfile(newAvatarUrl: url),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildLabel('Email'),
              const SizedBox(height: 6),
              _buildDisabledInput(email),
              const SizedBox(height: AppSpacing.xs),
              _buildLabel('Username'),
              const SizedBox(height: 6),
              _buildInput(_usernameController),
              const SizedBox(height: AppSpacing.xs),
              _buildLabel('Bio'),
              const SizedBox(height: 6),
              _buildInput(_bioController),
              const SizedBox(height: AppSpacing.xs),
              _buildLabel('Skills to Teach'),
              const SizedBox(height: 6),
              _buildInput(_skillsToTeachController),
              const SizedBox(height: AppSpacing.xs),
              _buildLabel('Skills to Learn'),
              const SizedBox(height: 6),
              _buildInput(_skillsToLearnController),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _loading ? null : () => _updateProfile(),
                style: AppDecor.primaryButton(),
                child: Text(
                  _loading ? 'Loading ...' : 'Update',
                  style: AppText.buttonLabel,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ElevatedButton(
                onPressed: () => Supabase.instance.client.auth.signOut(),
                style: AppDecor.secondaryButton(),
                child: const Text('Sign Out', style: AppText.buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: AppText.label);

  Widget _buildInput(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: AppDecor.outlinedField,
    );
  }

  Widget _buildDisabledInput(String value) {
    return TextField(
      controller: TextEditingController(text: value),
      enabled: false,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFd1d1d1)),
        ),
        contentPadding: EdgeInsets.all(12),
        fillColor: Color(0xFFf2f2f2),
        filled: true,
      ),
      style: const TextStyle(color: Color(0xFF9e9e9e)),
    );
  }
}
