import 'package:flutter/material.dart';

class QuestTag extends StatelessWidget {
  final String label;
  final Color bg;
  const QuestTag({super.key, required this.label, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF3d2e22)),
      ),
    );
  }
}
