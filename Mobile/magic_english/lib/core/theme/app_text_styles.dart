import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/theme/app_colors.dart';

class AppTextStyles {
  static TextStyle appTitle() => GoogleFonts.lexend(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle screenTitle() => GoogleFonts.lexend(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle subtitle() =>
      GoogleFonts.lexend(fontSize: 14, color: AppColors.placeholder);

  static TextStyle label() =>
      GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle button() => GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle link({Color? color}) => GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.primary,
    decoration: TextDecoration.underline,
  );

  static TextStyle body({Color? color}) =>
      GoogleFonts.lexend(fontSize: 14, color: color ?? AppColors.placeholder);
}
