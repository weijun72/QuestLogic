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
  final _skillFilterController = TextEditingController();
  final _locationFilterController = TextEditingController();

  List<Map<String, dynamic>> _posts = [];
  Set<String> _acceptedPostIds = {};
  bool _loading = true;
  String? _error;
  bool _showFilters = false;
  String _skillFilter = '';
  String _locationFilter = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _skillFilterController.dispose();
    _locationFilterController.dispose();
    super.dispose();
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
              'id, title, description, skill_offered, skill_wanted, location, created_at, user_id, profiles(username)',
            )
            .order('created_at', ascending: false)
            .limit(50);
      } catch (_) {
        data = await _supabase
            .from('posts')
            .select(
              'id, title, description, skill_offered, skill_wanted, location, created_at, user_id',
            )
            .order('created_at', ascending: false)
            .limit(50);
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

  void _applyFilters() {
    setState(() {
      _skillFilter = _skillFilterController.text.trim().toLowerCase();
      _locationFilter = _locationFilterController.text.trim().toLowerCase();
    });
  }

  void _clearFilters() {
    _skillFilterController.clear();
    _locationFilterController.clear();
    setState(() {
      _skillFilter = '';
      _locationFilter = '';
    });
  }

  bool get _hasActiveFilters =>
      _skillFilter.isNotEmpty || _locationFilter.isNotEmpty;

  List<Map<String, dynamic>> get _filteredPosts {
    final currentUserId = _supabase.auth.currentUser?.id;
    return _posts.where((p) {
      if (_acceptedPostIds.contains(p['id'])) return false;
      if (p['user_id'] == currentUserId) return false;

      if (_skillFilter.isNotEmpty) {
        final offered = (p['skill_offered'] ?? '').toLowerCase();
        final wanted = (p['skill_wanted'] ?? '').toLowerCase();
        if (!offered.contains(_skillFilter) && !wanted.contains(_skillFilter)) {
          return false;
        }
      }

      if (_locationFilter.isNotEmpty) {
        final location = (p['location'] ?? '').toLowerCase();
        if (!location.contains(_locationFilter)) return false;
      }

      return true;
    }).toList();
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                partnerId: posterId,
                partnerName: profile?['username'] ?? 'User',
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
    final user = _supabase.auth.currentUser;
    final availablePosts = _filteredPosts;

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
                      // Hero banner
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

                      // Recent Posts header + filter toggle
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Recent Posts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => _showFilters = !_showFilters),
                            icon: Icon(
                              _showFilters
                                  ? Icons.filter_list_off
                                  : Icons.filter_list,
                              size: 18,
                              color: _hasActiveFilters
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                            label: Text(
                              _hasActiveFilters ? 'Filtered' : 'Filter',
                              style: TextStyle(
                                fontSize: 13,
                                color: _hasActiveFilters
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                fontWeight: _hasActiveFilters
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Filter panel
                      if (_showFilters) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.onPrimary,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Filter by skill',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _skillFilterController,
                                decoration: AppDecor.textField(
                                  hint: 'e.g. Python, Guitar...',
                                  prefixIcon: const Icon(
                                    Icons.school_outlined,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                                onSubmitted: (_) => _applyFilters(),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Text(
                                'Filter by location',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _locationFilterController,
                                decoration: AppDecor.textField(
                                  hint: 'e.g. Singapore, Clementi...',
                                  prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                                onSubmitted: (_) => _applyFilters(),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _applyFilters,
                                      style: AppDecor.primaryButton(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                      child: const Text(
                                        'Apply',
                                        style: AppText.buttonLabel,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _clearFilters,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppColors.textMuted,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Clear',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
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
                            child: const Text(
                              'Retry',
                              style: AppText.buttonLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (availablePosts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 56,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _hasActiveFilters
                              ? 'No posts match your filters'
                              : 'No posts yet',
                          style: AppText.emptyStateTitle,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _hasActiveFilters
                              ? 'Try adjusting or clearing your filters'
                              : 'Be the first to post a skill swap!',
                          style: AppText.emptyStateSubtitle,
                        ),
                        if (_hasActiveFilters) ...[
                          const SizedBox(height: AppSpacing.lg),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text(
                              'Clear filters',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ],
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
