import 'package:flutter/material.dart';
import 'quest_list.dart';
import '../../../services/widgets/skill_tag.dart';

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3d2e22),
                    ),
                  ),
                ),
                if (mode == QuestListMode.accepted && completed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF879183).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF879183),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
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
                    SkillTag(label: '🎓 $offered', bg: const Color(0xFFe7d8c9)),
                  if (offered.isNotEmpty && wanted.isNotEmpty)
                    const SizedBox(width: 8),
                  if (wanted.isNotEmpty)
                    SkillTag(label: '🔍 $wanted', bg: const Color(0xFFdce4dc)),
                ],
              ),
            ],

            // Delete button — Quests Posted tab
            if (mode == QuestListMode.posted && onDelete != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

            // Complete button — My Quests tab
            if (mode == QuestListMode.accepted &&
                onComplete != null &&
                !completed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Color(0xFFe7d8c9),
                  ),
                  label: const Text(
                    'Complete',
                    style: TextStyle(
                      color: Color(0xFFe7d8c9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6b5a48),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
