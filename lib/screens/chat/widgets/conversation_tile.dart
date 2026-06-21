import 'package:flutter/material.dart';
import '../../../styles.dart';
import '../../../utils/time_utils.dart';
import '../../../widgets/initial_avatar.dart';

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
    final time = shortTime(message['created_at'] as String?);

    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: InitialAvatar(name: username, radius: 24),
      title: Text(username, style: AppText.cardTitle),
      subtitle: Text(
        isMine ? 'You: $content' : content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
      ),
      trailing: Text(time, style: AppText.cardMeta),
    );
  }
}
