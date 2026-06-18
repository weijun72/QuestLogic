import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../chat/chat_detail_screen.dart';
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
  Set<String> _acceptedPostIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadPosts(), _loadAcceptances()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadPosts() async {
    final userId = widget.profile['id'];
    if (userId == null) return;
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
    } catch (_) {}
  }

  Future<void> _loadAcceptances() async {
    try {
      final data = await _supabase.from('quest_acceptances').select('post_id');
      if (mounted) {
        setState(() {
          _acceptedPostIds = (data as List)
              .map((a) => a['post_id'] as String)
              .toSet();
        });
      }
    } catch (_) {}
  }

  Future<void> _acceptPost(Map<String, dynamic> post) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    final posterId = widget.profile['id'];
    final postId = post['id'];

    if (currentUserId == null || currentUserId == posterId) return;

    try {
      // Insert acceptance
      await _supabase.from('quest_acceptances').insert({
        'post_id': postId,
        'acceptor_id': currentUserId,
        'poster_id': posterId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Send initial message to start chat
      await _supabase.from('messages').insert({
        'sender_id': currentUserId,
        'receiver_id': posterId,
        'content':
            '👋 I accepted your quest: "${post['title']}"! Let\'s connect.',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        // Mark post as accepted locally
        setState(() => _acceptedPostIds.add(postId as String));

        // Show success and navigate to chat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quest accepted! Starting chat...')),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                partnerId: posterId as String,
                partnerName: widget.profile['username'] ?? 'User',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final username = profile['username'] ?? 'User';
    final bio = profile['bio'] ?? '';
    final teach = profile['skillsToTeach'] ?? '';
    final learn = profile['skillsToLearn'] ?? '';
    final currentUserId = _supabase.auth.currentUser?.id;
    final isOwnProfile = currentUserId == profile['id'];

    // Filter out accepted posts
    final availablePosts = _posts
        .where((p) => !_acceptedPostIds.contains(p['id']))
        .toList();

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
                  // Message button
                  if (!isOwnProfile) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            partnerId: profile['id'] as String,
                            partnerName: username,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Color(0xFF6b5a48),
                      ),
                      label: const Text(
                        'Message',
                        style: TextStyle(color: Color(0xFF6b5a48)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFe7d8c9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
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
          else if (availablePosts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No available posts',
                  style: TextStyle(color: Color(0xFF86939e), fontSize: 15),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final post = availablePosts[i];
                  return _PostWithAcceptCard(
                    post: post,
                    isOwnProfile: isOwnProfile,
                    onAccept: () => _acceptPost(post),
                  );
                }, childCount: availablePosts.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostWithAcceptCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool isOwnProfile;
  final VoidCallback onAccept;

  const _PostWithAcceptCard({
    required this.post,
    required this.isOwnProfile,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final title = post['title'] ?? '';
    final description = post['description'] ?? '';
    final offered = post['skill_offered'] ?? '';
    final wanted = post['skill_wanted'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3d2e22),
              ),
            ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6b5a48)),
            ),
          ],
          if (offered.isNotEmpty || wanted.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (offered.isNotEmpty)
                  _tag('🎓 $offered', const Color(0xFFe7d8c9)),
                if (wanted.isNotEmpty)
                  _tag('🔍 $wanted', const Color(0xFFdce4dc)),
              ],
            ),
          ],
          // Accept button — only show if viewing someone else's profile
          if (!isOwnProfile) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6b5a48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  'Accept Quest',
                  style: TextStyle(
                    color: Color(0xFFe7d8c9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tag(String label, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 11, color: Color(0xFF3d2e22)),
    ),
  );
}
