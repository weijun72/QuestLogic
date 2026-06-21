import 'package:flutter/material.dart';
import '../../../styles.dart';
import '../../../widgets/skill_tag.dart';
import 'quest_list.dart';

class QuestCard extends StatelessWidget {
  final Map<String, dynamic> quest;
  final QuestListMode mode;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;

  const QuestCard({
    super.key,
    required this.quest,
    required this.mode,
    this.onDelete,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final title = quest['title'] ?? '';
    final description = quest['description'] ?? '';
    final offered = quest['skill_offered'] ?? '';
    final wanted = quest['skill_wanted'] ?? '';
    final completed = quest['completed'] == true;

    return Container(
      margin: AppSpacing.cardMargin,
      decoration: AppDecor.card(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: AppText.cardTitle)),
                if (mode == QuestListMode.accepted && completed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.cardBody,
              ),
            ],
            if (offered.isNotEmpty || wanted.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (offered.isNotEmpty)
                    SkillTag(label: '🎓 $offered', bg: AppColors.onPrimary),
                  if (offered.isNotEmpty && wanted.isNotEmpty)
                    const SizedBox(width: AppSpacing.sm),
                  if (wanted.isNotEmpty)
                    SkillTag(label: '🔍 $wanted', bg: const Color(0xFFdce4dc)),
                ],
              ),
            ],
            if (mode == QuestListMode.posted && onDelete != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.danger,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  style: AppDecor.dangerOutlineButton(),
                ),
              ),
            ],
            if (mode == QuestListMode.accepted &&
                onComplete != null &&
                !completed) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.onPrimary,
                  ),
                  label: const Text('Complete', style: AppText.buttonLabel),
                  style: AppDecor.primaryButton(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
