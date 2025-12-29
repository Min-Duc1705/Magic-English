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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 26),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onMorePressed,
            child: const Icon(Icons.more_vert, size: 26),
          ),
        ],
      ),
    );
  }
}
