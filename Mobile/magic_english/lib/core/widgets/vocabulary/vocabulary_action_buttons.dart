import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VocabularyActionButtons extends StatelessWidget {
  final VoidCallback onKnowWord;
  final VoidCallback onReviewAgain;
  final Color primaryColor;
  final String knowText;
  final String reviewText;

  const VocabularyActionButtons({
    super.key,
    required this.onKnowWord,
    required this.onReviewAgain,
    this.primaryColor = const Color(0xFF4A90E2),
    this.knowText = 'I know this word',
    this.reviewText = 'Review again',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onKnowWord,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  knowText,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onReviewAgain,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  reviewText,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
