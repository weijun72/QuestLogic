import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created!')),
        );
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
      backgroundColor: const Color(0xFFfff4e9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Post',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3d2e22),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Share a skill you can teach or want to learn',
                style: TextStyle(fontSize: 14, color: Color(0xFF86939e)),
              ),
              const SizedBox(height: 24),
              _label('Title *'),
              _field(_titleController, 'e.g. Teaching guitar basics'),
              const SizedBox(height: 16),
              _label('Description'),
              _field(_descriptionController,
                  'Tell people more about what you offer or want...', maxLines: 4),
              const SizedBox(height: 16),
              _label('Skill I can teach *'),
              _field(_offeredController, 'e.g. Python, Guitar, Cooking'),
              const SizedBox(height: 16),
              _label('Skill I want to learn'),
              _field(_wantedController, 'e.g. Spanish, Drawing, Chess'),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6b5a48),
                    foregroundColor: const Color(0xFFe7d8c9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Color(0xFFe7d8c9), strokeWidth: 2))
                      : const Text('Post',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3d2e22))),
      );

  Widget _field(TextEditingController ctrl, String hint,
          {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFc4b09a)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}
