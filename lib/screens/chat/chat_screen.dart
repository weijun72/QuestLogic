import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../styles.dart';
import 'chat_detail_screen.dart';
import 'widgets/conversation_tile.dart';

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

      final seen = <String>{};
      final convs = <Map<String, dynamic>>[];
      for (final msg in List<Map<String, dynamic>>.from(data)) {
        final isMine = msg['sender_id'] == userId;
        final partnerMap = isMine
            ? msg['receiver'] as Map?
            : msg['sender'] as Map?;
        final partnerId =
            partnerMap?['id'] as String? ??
            (isMine ? msg['receiver_id'] : msg['sender_id']) as String;

        if (seen.add(partnerId)) {
          msg['profiles'] = {
            'id': partnerId,
            'username': partnerMap?['username'] ?? 'User',
          };
          msg['_partnerId'] = partnerId;
          convs.add(msg);
        }
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
      backgroundColor: AppScaffold.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text('Chat', style: AppText.screenTitle),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Your conversations', style: AppText.screenSubtitle),
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
                            color: AppColors.accent,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'No conversations yet',
                            style: AppText.emptyStateTitle,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            'Accept a quest to start chatting!',
                            style: AppText.emptyStateSubtitle,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      child: ListView.separated(
                        itemCount: _conversations.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 72,
                          color: AppColors.onPrimary,
                        ),
                        itemBuilder: (context, i) {
                          final msg = _conversations[i];
                          final partnerId = msg['_partnerId'] as String;
                          final partnerName =
                              (msg['profiles'] as Map)['username'] as String;

                          return ConversationTile(
                            message: msg,
                            currentUserId: currentUserId,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(
                                  partnerId: partnerId,
                                  partnerName: partnerName,
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
