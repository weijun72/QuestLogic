import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Try with foreign key join first; fall back to plain select if it fails
      List<dynamic> data;
      try {
        data = await _supabase
            .from('posts')
            .select(
                'id, title, description, skill_offered, skill_wanted, created_at, profiles(username)')
            .order('created_at', ascending: false)
            .limit(20);
      } catch (_) {
        data = await _supabase
            .from('posts')
            .select('id, title, description, skill_offered, skill_wanted, created_at')
            .order('created_at', ascending: false)
            .limit(20);
      }
      if (mounted) {
        setState(() => _posts = List<Map<String, dynamic>>.from(data));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFfff4e9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPosts,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back 👋',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3d2e22)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF86939e)),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6b5a48),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Share a skill,\nlearn something new.',
                              style: TextStyle(
                                color: Color(0xFFe7d8c9),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Post what you can teach and what you want to learn.',
                              style: TextStyle(
                                  color: Color(0xFFc4b09a), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Recent Posts',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3d2e22)),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Color(0xFFc4b09a)),
                          const SizedBox(height: 12),
                          Text(_error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color(0xFF86939e), fontSize: 13)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadPosts,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6b5a48)),
                            child: const Text('Retry',
                                style:
                                    TextStyle(color: Color(0xFFe7d8c9))),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_posts.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.article_outlined,
                            size: 56, color: Color(0xFFc4b09a)),
                        SizedBox(height: 12),
                        Text('No posts yet',
                            style: TextStyle(
                                color: Color(0xFF86939e), fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Be the first to post a skill swap!',
                            style: TextStyle(
                                color: Color(0xFFc4b09a), fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => PostCard(post: _posts[i]),
                      childCount: _posts.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
