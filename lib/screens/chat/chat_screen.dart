import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/conversation_tile.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await _supabase
          .from('messages')
          .select(
              'id, content, created_at, sender_id, receiver_id, profiles!messages_sender_id_fkey(username)')
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false)
          .limit(50);

      final seen = <String>{};
      final convs = <Map<String, dynamic>>[];
      for (final msg in List<Map<String, dynamic>>.from(data)) {
        final partner = msg['sender_id'] == userId
            ? msg['receiver_id']
            : msg['sender_id'];
        if (seen.add(partner as String)) convs.add(msg);
      }
      if (mounted) setState(() => _conversations = convs);
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
                'Chat',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3d2e22),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Your conversations',
                style: TextStyle(fontSize: 14, color: Color(0xFF86939e)),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _conversations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.chat_bubble_outline,
                                  size: 56, color: Color(0xFFc4b09a)),
                              SizedBox(height: 12),
                              Text('No conversations yet',
                                  style: TextStyle(
                                      color: Color(0xFF86939e),
                                      fontSize: 16)),
                              SizedBox(height: 4),
                              Text('Browse profiles and start chatting!',
                                  style: TextStyle(
                                      color: Color(0xFFc4b09a),
                                      fontSize: 13)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadConversations,
                          child: ListView.separated(
                            itemCount: _conversations.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              indent: 72,
                              color: Color(0xFFe7d8c9),
                            ),
                            itemBuilder: (context, i) {
                              final msg = _conversations[i];
                              final currentId =
                                  _supabase.auth.currentUser?.id ?? '';
                              final partnerId = msg['sender_id'] == currentId
                                  ? msg['receiver_id']
                                  : msg['sender_id'];
                              final partnerName =
                                  (msg['profiles'] as Map?)?['username'] ??
                                      'User';
                              return ConversationTile(
                                message: msg,
                                currentUserId: currentId,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatDetailScreen(
                                      partnerId: partnerId as String,
                                      partnerName: partnerName as String,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
