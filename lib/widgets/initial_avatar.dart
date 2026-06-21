import 'package:flutter/material.dart';
import '../styles.dart';

/// Circle avatar showing the first letter of a name.
/// Replaces the CircleAvatar(...) block that was duplicated in
/// ProfileCard, UserProfileScreen, ChatScreen, and HomePostCard.
class InitialAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final double fontSize;

  const InitialAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.onPrimary,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
