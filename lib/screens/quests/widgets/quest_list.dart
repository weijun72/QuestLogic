import 'package:flutter/material.dart';
import '../../../styles.dart';
import 'quest_card.dart';

enum QuestListMode { posted, accepted }

class QuestList extends StatelessWidget {
  final List<Map<String, dynamic>> quests;
  final QuestListMode mode;
  final Future<void> Function() onRefresh;
  final void Function(Map<String, dynamic> post)? onDelete;
  final void Function(Map<String, dynamic> post)? onComplete;

  const QuestList({
    super.key,
    required this.quests,
    required this.mode,
    required this.onRefresh,
    this.onDelete,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 56,
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              mode == QuestListMode.posted
                  ? 'No quests posted yet'
                  : 'No quests accepted yet',
              style: AppText.emptyStateTitle,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: quests.length,
        itemBuilder: (context, i) => QuestCard(
          quest: quests[i],
          mode: mode,
          onDelete: onDelete != null ? () => onDelete!(quests[i]) : null,
          onComplete: onComplete != null ? () => onComplete!(quests[i]) : null,
        ),
      ),
    );
  }
}
