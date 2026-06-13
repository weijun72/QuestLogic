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
  List<Map<String, dynamic>> _allQuests = [];
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
    try {
      final all = await _supabase
          .from('posts')
          .select(
              'id, title, description, skill_offered, skill_wanted, created_at, profiles(username)')
          .order('created_at', ascending: false)
          .limit(30);
      final mine = userId != null
          ? await _supabase
              .from('posts')
              .select(
                  'id, title, description, skill_offered, skill_wanted, created_at')
              .eq('user_id', userId)
              .order('created_at', ascending: false)
          : [];
      if (mounted) {
        setState(() {
          _allQuests = List<Map<String, dynamic>>.from(all);
          _myQuests = List<Map<String, dynamic>>.from(mine);
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                'Skill-swap requests from the community',
                style: TextStyle(fontSize: 14, color: Color(0xFF86939e)),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF6b5a48),
              unselectedLabelColor: const Color(0xFF86939e),
              indicatorColor: const Color(0xFF6b5a48),
              tabs: const [
                Tab(text: 'All Quests'),
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
                            quests: _allQuests,
                            showAuthor: true,
                            onRefresh: _loadQuests),
                        QuestList(
                            quests: _myQuests,
                            showAuthor: false,
                            onRefresh: _loadQuests),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
