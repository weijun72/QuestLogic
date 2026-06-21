import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../styles.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _supabase = Supabase.instance.client;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _offeredController = TextEditingController();
  final _wantedController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _offeredController.dispose();
    _wantedController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final offered = _offeredController.text.trim();
    if (title.isEmpty || offered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and skill offered are required')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await _supabase.from('posts').insert({
        'user_id': _supabase.auth.currentUser?.id,
        'title': title,
        'description': _descriptionController.text.trim(),
        'skill_offered': offered,
        'skill_wanted': _wantedController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        _titleController.clear();
        _descriptionController.clear();
        _offeredController.clear();
        _wantedController.clear();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Post created!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppScaffold.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Post', style: AppText.screenTitle),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Share a skill you can teach or want to learn',
                style: AppText.screenSubtitle,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _label('Title *'),
              _field(_titleController, 'e.g. Teaching guitar basics'),
              const SizedBox(height: AppSpacing.lg),
              _label('Description'),
              _field(
                _descriptionController,
                'Tell people more about what you offer or want...',
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.lg),
              _label('Skill I can teach *'),
              _field(_offeredController, 'e.g. Python, Guitar, Cooking'),
              const SizedBox(height: AppSpacing.lg),
              _label('Skill I want to learn'),
              _field(_wantedController, 'e.g. Spanish, Drawing, Chess'),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: AppDecor.primaryButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ).copyWith(
                    foregroundColor:
                        const WidgetStatePropertyAll(AppColors.onPrimary),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      );

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: AppDecor.textField(hint: hint),
      );
}
