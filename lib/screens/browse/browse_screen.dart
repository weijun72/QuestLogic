import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/profile_card.dart';
import 'user_profile_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _profiles = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select(
            'id, username, bio, skillsToTeach, skillsToLearn, avatar_url',
          );

      if (mounted) {
        setState(() {
          _profiles = List<Map<String, dynamic>>.from(data);
          _filtered = _profiles;
        });
      }
    } catch (e) {
      debugPrint('Browse error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _profiles
          : _profiles.where((p) {
              final name = (p['username'] ?? '').toLowerCase();
              final teach = (p['skillsToTeach'] ?? '').toLowerCase();
              final learn = (p['skillsToLearn'] ?? '').toLowerCase();
              return name.contains(q) || teach.contains(q) || learn.contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff4e9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Browse',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3d2e22),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Find people to swap skills with',
                    style: TextStyle(fontSize: 14, color: Color(0xFF86939e)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or skill...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF86939e),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.people_outline,
                            size: 56,
                            color: Color(0xFFc4b09a),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No users found',
                            style: TextStyle(
                              color: Color(0xFF86939e),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProfiles,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) => ProfileCard(
                          profile: _filtered[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UserProfileScreen(profile: _filtered[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
