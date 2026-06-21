import 'package:flutter/material.dart';
import '../../../styles.dart';
import '../../../utils/time_utils.dart';
import '../../../widgets/initial_avatar.dart';
import '../../../widgets/skill_tag.dart';

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
      margin: AppSpacing.cardMargin,
      decoration: AppDecor.card(),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialAvatar(name: username, radius: 16, fontSize: 13),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(username, style: AppText.cardTitle)),
                Text(timeAgo(createdAt), style: AppText.cardMeta),
              ],
            ),
            if (title.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
            if (description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppText.cardBody,
              ),
            ],
            if (offered.isNotEmpty || wanted.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                children: [
                  if (offered.isNotEmpty)
                    SkillTag(label: '🎓 $offered', bg: AppColors.onPrimary),
                  if (wanted.isNotEmpty)
                    SkillTag(label: '🔍 $wanted', bg: const Color(0xFFdce4dc)),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccept,
                style: AppDecor.primaryButton(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Accept Quest', style: AppText.buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
