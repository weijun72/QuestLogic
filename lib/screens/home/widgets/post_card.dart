import 'package:flutter/material.dart';
import '../../../services/widgets/skill_tag.dart';
import '../../../services/widgets/time_utils.dart';

class HomePostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onAccept;
  const HomePostCard({super.key, required this.post, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final profile = post['profiles'] as Map<String, dynamic>?;
    final username = profile?['username'] ?? 'User';
    final title = post['title'] ?? '';
    final description = post['description'] ?? '';
    final offered = post['skill_offered'] ?? '';
    final wanted = post['skill_wanted'] ?? '';
    final createdAt = post['created_at'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFe7d8c9),
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6b5a48),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3d2e22),
                    ),
                  ),
                ),
                Text(
                  timeAgo(createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF86939e),
                  ),
                ),
              ],
            ),
            if (title.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3d2e22),
                ),
              ),
            ],
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6b5a48)),
              ),
            ],
            if (offered.isNotEmpty || wanted.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (offered.isNotEmpty)
                    SkillTag(label: '🎓 $offered', bg: const Color(0xFFe7d8c9)),
                  if (wanted.isNotEmpty)
                    SkillTag(label: '🔍 $wanted', bg: const Color(0xFFdce4dc)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6b5a48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  'Accept Quest',
                  style: TextStyle(
                    color: Color(0xFFe7d8c9),
                    fontWeight: FontWeight.bold,
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
