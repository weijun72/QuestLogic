import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/quest_service.dart';
import '../../styles.dart';
import '../../widgets/initial_avatar.dart';
import '../../widgets/skill_tag.dart';
import '../chat/chat_detail_screen.dart';

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
      final ids = await QuestService.getAcceptedPostIds();
      if (mounted) setState(() => _acceptedPostIds = ids);
    } catch (_) {}
  }

  Future<void> _acceptPost(Map<String, dynamic> post) async {
    final posterId = widget.profile['id'] as String?;
    final postId = post['id'] as String?;
    if (posterId == null || postId == null) return;

    try {
      await QuestService.acceptQuest(
        postId: postId,
        posterId: posterId,
        questTitle: post['title'] ?? '',
      );

      if (mounted) {
        setState(() => _acceptedPostIds.add(postId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quest accepted! Starting chat...')),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                partnerId: posterId,
                partnerName: widget.profile['username'] ?? 'User',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
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

    final availablePosts =
        _posts.where((p) => !_acceptedPostIds.contains(p['id'])).toList();

    return Scaffold(
      backgroundColor: AppScaffold.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: Text(username),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  InitialAvatar(name: username, radius: 40, fontSize: 32),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    username,
                    style: const TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      if (teach.isNotEmpty)
                        SkillChip(label: '🎓 $teach', color: AppColors.onPrimary),
                      if (learn.isNotEmpty)
                        SkillChip(label: '🔍 $learn', color: AppColors.accent),
                    ],
                  ),
                  if (!isOwnProfile) ...[
                    const SizedBox(height: AppSpacing.lg),
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
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Message',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.onPrimary,
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
                  color: AppColors.textDark,
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
                child: Text('No available posts', style: AppText.emptyStateTitle),
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
      margin: AppSpacing.cardMargin,
      padding: AppSpacing.cardPadding,
      decoration: AppDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) Text(title, style: AppText.cardTitle),
          if (description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.cardBody,
            ),
          ],
          if (offered.isNotEmpty || wanted.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (offered.isNotEmpty)
                  SkillTag(label: '🎓 $offered', bg: AppColors.onPrimary),
                if (wanted.isNotEmpty)
                  SkillTag(label: '🔍 $wanted', bg: const Color(0xFFdce4dc)),
              ],
            ),
          ],
          if (!isOwnProfile) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccept,
                style: AppDecor.primaryButton(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Accept Quest', style: AppText.buttonLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
