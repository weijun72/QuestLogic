import 'package:flutter/material.dart';

class ConversationTile extends StatelessWidget {
  final Map<String, dynamic> message;
  final String currentUserId;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final profile = message['profiles'] as Map<String, dynamic>?;
    final username = profile?['username'] ?? 'User';
    final content = message['content'] ?? '';
    final isMine = message['sender_id'] == currentUserId;
    final createdAt = message['created_at'] != null
        ? DateTime.tryParse(message['created_at'])
        : null;
    final time = createdAt != null
        ? '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
        : '';

    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFFe7d8c9),
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Color(0xFF6b5a48),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        username,
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
        style: const TextStyle(fontSize: 13, color: Color(0xFF86939e)),
      ),
      trailing: Text(time,
          style: const TextStyle(fontSize: 11, color: Color(0xFF86939e))),
    );
  }
}
