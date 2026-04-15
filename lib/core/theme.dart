import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF1C1C1E);
  static const backgroundSecondary = Color(0xFF2C2C2E);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8E8E93);
  static const separator = Color(0xFF38383A);
  static const accent = Color(0xFF5856D6); // iOS system indigo — idle 상태
  static const accentArmed = Color(0xFF30D158); // iOS system green — 대기 중 상태
  static const error = Color(0xFFFF453A); // iOS system red
  static const dotEmpty = Color(0xFF3A3A3C);
  static const dotFilled = accent;
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.backgroundSecondary,
      error: AppColors.error,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      ),
    ),
    dividerColor: AppColors.separator,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? Colors.white : Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.backgroundSecondary;
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF2C2C2E),
      titleTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF3A3A3C),
      contentTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
