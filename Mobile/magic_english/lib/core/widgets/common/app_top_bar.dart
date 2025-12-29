import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? rightAction;

  const AppTopBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.rightAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : const Color(0xFF333333);
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, size: 28, color: iconColor),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Spacer(),
          rightAction ?? const SizedBox(width: 28),
        ],
      ),
    );
  }
}
