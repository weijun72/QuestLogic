import 'package:flutter/material.dart';
import 'skill_chip.dart';

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onTap;
  const ProfileCard({super.key, required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final username = profile['username'] ?? 'Unknown';
    final bio = profile['bio'] ?? '';
    final teach = profile['skillsToTeach'] ?? '';
    final learn = profile['skillsToLearn'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFe7d8c9),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF6b5a48),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF3d2e22),
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Color(0xFFc4b09a), size: 20),
                    ],
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF86939e)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (teach.isNotEmpty)
                    SkillChip(
                        label: 'Teaches: $teach',
                        color: const Color(0xFF6b5a48)),
                  if (teach.isNotEmpty && learn.isNotEmpty)
                    const SizedBox(height: 4),
                  if (learn.isNotEmpty)
                    SkillChip(
                        label: 'Wants: $learn',
                        color: const Color(0xFF879183)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
