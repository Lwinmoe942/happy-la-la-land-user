import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFFFF6EA);
  static const ink = Color(0xFF1E2430);
  static const coral = Color(0xFFD83A45);
  static const coralSoft = Color(0xFFFFE8E6);
  static const sun = Color(0xFFF5A524);
  static const teal = Color(0xFF0E7C72);
  static const tealSoft = Color(0xFFE5F6F3);
  static const line = Color(0xFFF0E2D0);
  static const muted = Color(0xFF6E6258);
  static const card = Colors.white;
}

ThemeData buildTheme() {
  const ink = AppColors.ink;
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.coral,
      onPrimary: Colors.white,
      secondary: AppColors.teal,
      surface: AppColors.card,
      onSurface: ink,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme
        .apply(bodyColor: ink, displayColor: ink)
        .copyWith(
          bodyLarge: const TextStyle(fontSize: 16, height: 1.45, color: ink),
          bodyMedium: const TextStyle(fontSize: 14, height: 1.4, color: ink),
          titleLarge: const TextStyle(
            fontSize: 22,
            height: 1.3,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFE7C8C4),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: Color(0xFFB3A79C)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.coral, width: 1.6),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
