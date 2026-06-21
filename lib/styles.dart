import 'package:flutter/material.dart';

/// Centralized design tokens for Quest Logic.
/// Import this file and use AppColors / AppText / AppDecor / AppSpacing
/// instead of repeating raw values across screens.
class AppColors {
  AppColors._();

  static const background = Color(0xFFfff4e9);
  static const primary = Color(0xFF6b5a48);
  static const secondary = Color(0xFF879183);
  static const onPrimary = Color(0xFFe7d8c9);
  static const accent = Color(0xFFc4b09a);
  static const textDark = Color(0xFF3d2e22);
  static const textMuted = Color(0xFF86939e);
  static const cardShadow = Color(0x0D000000); // black @ 5%
  static const danger = Color(0xFFD32F2F);
  static const success = secondary;
}

class AppText {
  AppText._();

  static const screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const screenSubtitle = TextStyle(
    fontSize: 14,
    color: AppColors.textMuted,
  );

  static const cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const cardBody = TextStyle(
    fontSize: 13,
    color: AppColors.primary,
  );

  static const cardMeta = TextStyle(
    fontSize: 11,
    color: AppColors.textMuted,
  );

  static const label = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static const buttonLabel = TextStyle(
    color: AppColors.onPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const tag = TextStyle(
    fontSize: 11,
    color: AppColors.textDark,
  );

  static const emptyStateTitle = TextStyle(
    color: AppColors.textMuted,
    fontSize: 16,
  );

  static const emptyStateSubtitle = TextStyle(
    color: AppColors.accent,
    fontSize: 13,
  );
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;

  static const screenPadding = EdgeInsets.fromLTRB(16, 20, 16, 16);
  static const cardPadding = EdgeInsets.all(14);
  static const cardMargin = EdgeInsets.only(bottom: 12);
}

class AppDecor {
  AppDecor._();

  static BoxDecoration card({double radius = 12}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static InputDecoration textField({
    String? hint,
    Widget? prefixIcon,
    bool filled = true,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.accent),
        prefixIcon: prefixIcon,
        filled: filled,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  /// Outlined-border style used on Auth screen TextFields.
  static const outlinedField = InputDecoration(
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.textMuted),
    ),
    contentPadding: EdgeInsets.all(12),
  );

  static ButtonStyle primaryButton({EdgeInsetsGeometry? padding}) =>
      ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        padding: padding ?? const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  static ButtonStyle secondaryButton({EdgeInsetsGeometry? padding}) =>
      ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.5),
        padding: padding ?? const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  static ButtonStyle dangerOutlineButton() => OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.danger),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
}

class AppScaffold {
  AppScaffold._();

  /// Standard Scaffold background used on every screen.
  static const backgroundColor = AppColors.background;
}
