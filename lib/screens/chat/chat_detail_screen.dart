import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../styles.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input_bar.dart';

class ChatDetailScreen extends StatefulWidget {
  final String partnerId;
  final String partnerName;
  const ChatDetailScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _supabase = Supabase.instance.client;
  final _msgController = TextEditingController();
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scroll.dispose();
    _supabase.removeAllChannels();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final userId = _supabase.auth.currentUser?.id ?? '';
    try {
      final data = await _supabase
          .from('messages')
          .select('id, content, created_at, sender_id')
          .or(
            'and(sender_id.eq.$userId,receiver_id.eq.${widget.partnerId}),'
            'and(sender_id.eq.${widget.partnerId},receiver_id.eq.$userId)',
          )
          .order('created_at', ascending: true);
      if (mounted) {
        setState(() => _messages = List<Map<String, dynamic>>.from(data));
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _subscribeRealtime() {
    final userId = _supabase.auth.currentUser?.id ?? '';
    _supabase
        .channel('chat_${userId}_${widget.partnerId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final row = payload.newRecord;
            final isRelevant = (row['sender_id'] == userId &&
                    row['receiver_id'] == widget.partnerId) ||
                (row['sender_id'] == widget.partnerId &&
                    row['receiver_id'] == userId);
            if (isRelevant && mounted) {
              setState(() => _messages.add(Map<String, dynamic>.from(row)));
              _scrollToBottom();
            }
          },
        )
        .subscribe();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    setState(() => _sending = true);
    try {
      await _supabase.from('messages').insert({
        'sender_id': _supabase.auth.currentUser?.id,
        'receiver_id': widget.partnerId,
        'content': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _supabase.auth.currentUser?.id ?? '';
    return Scaffold(
      backgroundColor: AppScaffold.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: Text(widget.partnerName),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                return MessageBubble(
                  content: msg['content'] ?? '',
                  isMine: msg['sender_id'] == userId,
                );
              },
            ),
          ),
          MessageInputBar(
            controller: _msgController,
            sending: _sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}
