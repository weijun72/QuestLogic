import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/skill_chip.dart';
import 'widgets/user_post_card.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const UserProfileScreen({super.key, required this.profile});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final userId = widget.profile['id'];
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final data = await _supabase
          .from('posts')
          .select(
            'id, title, description, skill_offered, skill_wanted, created_at',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() => _posts = List<Map<String, dynamic>>.from(data));
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final username = profile['username'] ?? 'User';
    final bio = profile['bio'] ?? '';
    final teach = profile['skillsToTeach'] ?? '';
    final learn = profile['skillsToLearn'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFfff4e9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6b5a48),
        foregroundColor: const Color(0xFFe7d8c9),
        title: Text(username),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF6b5a48),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFe7d8c9),
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFF6b5a48),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    username,
                    style: const TextStyle(
                      color: Color(0xFFe7d8c9),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFc4b09a),
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      if (teach.isNotEmpty)
                        SkillChip(
                          label: '🎓 $teach',
                          color: const Color(0xFFe7d8c9),
                        ),
                      if (learn.isNotEmpty)
                        SkillChip(
                          label: '🔍 $learn',
                          color: const Color(0xFFc4b09a),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                '$username\'s Posts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3d2e22),
                ),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_posts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No posts yet',
                  style: TextStyle(color: Color(0xFF86939e), fontSize: 15),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => UserPostCard(post: _posts[i]),
                  childCount: _posts.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
