import 'package:flutter/material.dart';
import 'quest_card.dart';

class QuestList extends StatelessWidget {
  final List<Map<String, dynamic>> quests;
  final bool showAuthor;
  final Future<void> Function() onRefresh;

  const QuestList({
    super.key,
    required this.quests,
    required this.showAuthor,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.emoji_events_outlined,
                size: 56, color: Color(0xFFc4b09a)),
            SizedBox(height: 12),
            Text('No quests yet',
                style: TextStyle(color: Color(0xFF86939e), fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: quests.length,
        itemBuilder: (context, i) =>
            QuestCard(quest: quests[i], showAuthor: showAuthor),
      ),
    );
  }
}
