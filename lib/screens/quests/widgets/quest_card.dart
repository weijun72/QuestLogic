import 'package:flutter/material.dart';
import 'quest_tag.dart';

class QuestCard extends StatelessWidget {
  final Map<String, dynamic> quest;
  final bool showAuthor;
  const QuestCard({super.key, required this.quest, required this.showAuthor});

  @override
  Widget build(BuildContext context) {
    final title = quest['title'] ?? '';
    final description = quest['description'] ?? '';
    final offered = quest['skill_offered'] ?? '';
    final wanted = quest['skill_wanted'] ?? '';
    final profile = quest['profiles'] as Map<String, dynamic>?;
    final author = profile?['username'] ?? '';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAuthor && author.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  author,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF86939e),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3d2e22),
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6b5a48)),
              ),
            ],
            if (offered.isNotEmpty || wanted.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (offered.isNotEmpty)
                    QuestTag(
                        label: '🎓 $offered',
                        bg: const Color(0xFFe7d8c9)),
                  if (offered.isNotEmpty && wanted.isNotEmpty)
                    const SizedBox(width: 8),
                  if (wanted.isNotEmpty)
                    QuestTag(
                        label: '🔍 $wanted',
                        bg: const Color(0xFFdce4dc)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
