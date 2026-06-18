import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _supabase.removeAllChannels();
    super.dispose();
  }

  void _subscribeRealtime() {
    final userId = _supabase.auth.currentUser?.id ?? '';
    _supabase
        .channel('chat_list_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (_) => _loadConversations(),
        )
        .subscribe();
  }

  Future<void> _loadConversations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await _supabase
          .from('messages')
          .select(
            'id, content, created_at, sender_id, receiver_id, '
            'sender:profiles!messages_sender_id_fkey(id, username), '
            'receiver:profiles!messages_receiver_id_fkey(id, username)',
          )
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false)
          .limit(100);

      // Deduplicate — one entry per partner
      final seen = <String>{};
      final convs = <Map<String, dynamic>>[];
      for (final msg in List<Map<String, dynamic>>.from(data)) {
        final partnerId = msg['sender_id'] == userId
            ? msg['receiver_id'] as String
            : msg['sender_id'] as String;
        if (seen.add(partnerId)) convs.add(msg);
      }

      if (mounted) setState(() => _conversations = convs);
    } catch (e) {
      debugPrint('Chat list error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _supabase.auth.currentUser?.id ?? '';

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
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 56,
                            color: Color(0xFFc4b09a),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                              color: Color(0xFF86939e),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Accept a quest to start chatting!',
                            style: TextStyle(
                              color: Color(0xFFc4b09a),
                              fontSize: 13,
                            ),
                          ),
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
                          final isMine = msg['sender_id'] == currentUserId;

                          // Get partner info correctly
                          final partnerMap = isMine
                              ? msg['receiver'] as Map?
                              : msg['sender'] as Map?;
                          final partnerId =
                              partnerMap?['id'] as String? ??
                              (isMine ? msg['receiver_id'] : msg['sender_id'])
                                  as String;
                          final partnerName =
                              partnerMap?['username'] as String? ?? 'User';
                          final content = msg['content'] as String? ?? '';
                          final createdAt = msg['created_at'] != null
                              ? DateTime.tryParse(msg['created_at'])
                              : null;
                          final time = createdAt != null
                              ? '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
                              : '';

                          return ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(
                                  partnerId: partnerId,
                                  partnerName: partnerName,
                                ),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFe7d8c9),
                              child: Text(
                                partnerName.isNotEmpty
                                    ? partnerName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Color(0xFF6b5a48),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            title: Text(
                              partnerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF3d2e22),
                              ),
                            ),
                            subtitle: Text(
                              isMine ? 'You: $content' : content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF86939e),
                              ),
                            ),
                            trailing: Text(
                              time,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF86939e),
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
