import 'package:flutter/material.dart';
import '../../../styles.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isMine;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isMine ? AppColors.onPrimary : AppColors.textDark,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
