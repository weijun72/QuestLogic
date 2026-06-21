import 'package:flutter/material.dart';
import '../../../styles.dart';
import '../../../widgets/initial_avatar.dart';
import '../../../widgets/skill_tag.dart';

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
        margin: AppSpacing.cardMargin,
        padding: const EdgeInsets.all(16),
        decoration: AppDecor.card(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialAvatar(name: username, radius: 24, fontSize: 18),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(username, style: AppText.cardTitle)),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ],
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  if (teach.isNotEmpty)
                    SkillChip(label: 'Teaches: $teach', color: AppColors.primary),
                  if (teach.isNotEmpty && learn.isNotEmpty)
                    const SizedBox(height: AppSpacing.xs),
                  if (learn.isNotEmpty)
                    SkillChip(label: 'Wants: $learn', color: AppColors.secondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
