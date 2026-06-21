import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/quest_service.dart';
import '../../styles.dart';
import '../chat/chat_detail_screen.dart';
import 'widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _posts = [];
  Set<String> _acceptedPostIds = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Future.wait([_loadPosts(), _loadAcceptances()]);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadPosts() async {
    try {
      List<dynamic> data;
      try {
        data = await _supabase
            .from('posts')
            .select(
              'id, title, description, skill_offered, skill_wanted, created_at, user_id, profiles(username)',
            )
            .order('created_at', ascending: false)
            .limit(20);
      } catch (_) {
        data = await _supabase
            .from('posts')
            .select(
              'id, title, description, skill_offered, skill_wanted, created_at, user_id',
            )
            .order('created_at', ascending: false)
            .limit(20);
      }
      if (mounted) {
        setState(() => _posts = List<Map<String, dynamic>>.from(data));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadAcceptances() async {
    try {
      final ids = await QuestService.getAcceptedPostIds();
      if (mounted) setState(() => _acceptedPostIds = ids);
    } catch (_) {}
  }

  Future<void> _acceptPost(Map<String, dynamic> post) async {
    final posterId = post['user_id'] as String?;
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
          final profile = post['profiles'] as Map<String, dynamic>?;
          final partnerName = profile?['username'] ?? 'User';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                partnerId: posterId,
                partnerName: partnerName,
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
    final user = _supabase.auth.currentUser;
    final currentUserId = user?.id;

    final availablePosts = _posts
        .where(
          (p) =>
              !_acceptedPostIds.contains(p['id']) &&
              p['user_id'] != currentUserId,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppScaffold.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome back 👋', style: AppText.screenTitle),
                      const SizedBox(height: AppSpacing.xs),
                      Text(user?.email ?? '', style: AppText.screenSubtitle),
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share a skill,\nlearn something new.',
                              style: TextStyle(
                                color: AppColors.onPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Post what you can teach and what you want to learn.',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Text(
                        'Recent Posts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.accent,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: _loadData,
                            style: AppDecor.primaryButton(),
                            child: const Text('Retry', style: AppText.buttonLabel),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (availablePosts.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 56,
                          color: AppColors.accent,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text('No posts yet', style: AppText.emptyStateTitle),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Be the first to post a skill swap!',
                          style: AppText.emptyStateSubtitle,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final post = availablePosts[i];
                      return HomePostCard(
                        post: post,
                        onAccept: () => _acceptPost(post),
                      );
                    }, childCount: availablePosts.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
