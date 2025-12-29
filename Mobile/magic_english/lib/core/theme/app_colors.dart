import 'package:flutter/material.dart';

/// Static color constants (unchanged for compatibility)
class AppColors {
  static const primary = Color(0xFF4A90E2);
  static const lightBg = Color(0xfff6f6f8);
  static const borderColor = Color(0xffd3cfe7);
  static const placeholder = Color(0xff594c9a);
  static const textDark = Color(0xff131022);
  static const white = Colors.white;

  // Dark mode colors
  static const darkBg = Color(0xFF121212);
  static const darkCard = Color(0xFF1E1E1E);
  static const darkSurface = Color(0xFF2D2D2D);
  static const darkBorder = Color(0xFF3D3D3D);
}

/// Dynamic color helper that adapts to current theme
class ThemeColors {
  final BuildContext context;
  late final bool isDark;

  ThemeColors(this.context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
  }

  // Background colors
  Color get background => isDark ? AppColors.darkBg : const Color(0xFFF8F9FA);
  Color get card => isDark ? AppColors.darkCard : Colors.white;
  Color get surface => isDark ? AppColors.darkSurface : const Color(0xFFF4F6F9);

  // Text colors
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF333333);
  Color get textSecondary =>
      isDark ? Colors.grey.shade400 : const Color(0xFF7F8C8D);
  Color get textHint => isDark ? Colors.grey.shade600 : Colors.grey.shade400;

  // Border colors
  Color get border => isDark ? AppColors.darkBorder : const Color(0xFFEAECEF);

  // Icon colors
  Color get iconPrimary => isDark ? Colors.white : const Color(0xFF333333);
  Color get iconSecondary => isDark ? Colors.grey.shade400 : Colors.grey;

  // Shadow
  Color get shadow =>
      isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05);

  // Static helper for quick access
  static ThemeColors of(BuildContext context) => ThemeColors(context);
}

/// Extension on BuildContext for easy access
extension ThemeColorsExtension on BuildContext {
  ThemeColors get colors => ThemeColors(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
