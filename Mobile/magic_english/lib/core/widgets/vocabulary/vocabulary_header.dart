import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VocabularyHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMorePressed;

  const VocabularyHeader({
    super.key,
    this.title = 'Vocabulary',
    this.onBackPressed,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white : const Color(0xFF333333);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, size: 26, color: contentColor),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onMorePressed,
            child: Icon(Icons.more_vert, size: 26, color: contentColor),
          ),
        ],
      ),
    );
  }
}
