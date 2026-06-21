import 'package:flutter/material.dart';
import '../styles.dart';

/// Small pill used for skill/offer tags across post cards, profile cards,
/// and quest cards. Replaces the previously duplicated _tag()/_chip()
/// helpers and QuestTag widget.
class SkillTag extends StatelessWidget {
  final String label;
  final Color bg;

  const SkillTag({super.key, required this.label, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppText.tag,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Outlined variant used on the Browse profile list (skill_chip.dart).
class SkillChip extends StatelessWidget {
  final String label;
  final Color color;

  const SkillChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
