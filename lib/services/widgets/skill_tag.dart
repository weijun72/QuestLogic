import 'package:flutter/material.dart';

class SkillTag extends StatelessWidget {
  final String label;
  final Color bg;
  const SkillTag({super.key, required this.label, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 11, color: Color(0xFF3d2e22)),
    ),
  );
}
