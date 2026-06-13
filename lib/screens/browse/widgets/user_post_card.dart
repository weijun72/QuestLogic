import 'package:flutter/material.dart';

class UserPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const UserPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final title = post['title'] ?? '';
    final description = post['description'] ?? '';
    final offered = post['skill_offered'] ?? '';
    final wanted = post['skill_wanted'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3d2e22),
              ),
            ),
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
              runSpacing: 4,
              children: [
                if (offered.isNotEmpty)
                  _tag('🎓 $offered', const Color(0xFFe7d8c9)),
                if (wanted.isNotEmpty)
                  _tag('🔍 $wanted', const Color(0xFFdce4dc)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tag(String label, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF3d2e22))),
      );
}
