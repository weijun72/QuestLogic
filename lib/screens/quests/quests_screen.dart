import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/quest_list.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _postedQuests = [];
  List<Map<String, dynamic>> _myQuests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuests() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      // Quests Posted — posts created by the current user
      final posted = await _supabase
          .from('posts')
          .select(
            'id, title, description, skill_offered, skill_wanted, created_at',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // My Quests — posts I accepted, that aren't yet completed
      final myAcceptances = await _supabase
          .from('quest_acceptances')
          .select(
            'id, post_id, completed, posts(id, title, description, skill_offered, skill_wanted, created_at)',
          )
          .eq('acceptor_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _postedQuests = List<Map<String, dynamic>>.from(posted);

          _myQuests = (myAcceptances as List).map((a) {
            final post = Map<String, dynamic>.from(
              a['posts'] as Map<String, dynamic>,
            );
            post['acceptance_id'] = a['id'];
            post['completed'] = a['completed'] ?? false;
            return post;
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Quests error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await _supabase.from('posts').delete().eq('id', postId);
      if (mounted) {
        setState(() => _postedQuests.removeWhere((p) => p['id'] == postId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Quest deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _completeQuest(String acceptanceId, String postId) async {
    try {
      await _supabase
          .from('quest_acceptances')
          .update({'completed': true})
          .eq('id', acceptanceId);
      if (mounted) {
        setState(() {
          final quest = _myQuests.firstWhere((q) => q['id'] == postId);
          quest['completed'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quest marked as complete!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _confirmDelete(String postId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quest'),
        content: Text(
          'Are you sure you want to delete "$title"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deletePost(postId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff4e9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                'Quests',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3d2e22),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Manage your skill-swap quests',
                style: TextStyle(fontSize: 14, color: Color(0xFF86939e)),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF6b5a48),
              unselectedLabelColor: const Color(0xFF86939e),
              indicatorColor: const Color(0xFF6b5a48),
              tabs: const [
                Tab(text: 'Quests Posted'),
                Tab(text: 'My Quests'),
              ],
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        QuestList(
                          quests: _postedQuests,
                          mode: QuestListMode.posted,
                          onRefresh: _loadQuests,
                          onDelete: (post) =>
                              _confirmDelete(post['id'], post['title'] ?? ''),
                        ),
                        QuestList(
                          quests: _myQuests,
                          mode: QuestListMode.accepted,
                          onRefresh: _loadQuests,
                          onComplete: (post) =>
                              _completeQuest(post['acceptance_id'], post['id']),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
