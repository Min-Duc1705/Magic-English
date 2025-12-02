import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/models/grammar/grammar.dart';

class GrammarSummaryCard extends StatelessWidget {
  final Grammar grammar;

  const GrammarSummaryCard({super.key, required this.grammar});

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Colors.white;
    const Color borderColor = Color(0xFFEAECEF);
    const Color error = Color(0xFFE94E77);
    const Color primary = Color(0xFF4A90E2);
    const Color suggestion = Color(0xFFF5A623);

    final spellingCount = grammar.getErrorCountByType('spelling');
    final punctuationCount = grammar.getErrorCountByType('punctuation');
    final clarityCount = grammar.getErrorCountByType('clarity');
    final grammarCount = grammar.getErrorCountByType('grammar');
    const Color grammarColor = Color(0xFF9B59B6); // Màu tím cho Grammar

    if (grammar.errors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF7ED321), size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Perfect! No errors found.",
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7ED321),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Summary of Suggestions",
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          _summaryItem(
            icon: Icons.spellcheck,
            iconColor: error,
            title:
                "$spellingCount Spelling ${spellingCount == 1 ? 'Error' : 'Errors'}",
          ),
          const SizedBox(height: 12),
          _summaryItem(
            icon: Icons.text_fields,
            iconColor: grammarColor,
            title:
                "$grammarCount Grammar ${grammarCount == 1 ? 'Error' : 'Errors'}",
          ),
          const SizedBox(height: 12),
          _summaryItem(
            icon: Icons.edit,
            iconColor: primary,
            title:
                "$punctuationCount Punctuation ${punctuationCount == 1 ? 'Mistake' : 'Mistakes'}",
          ),
          const SizedBox(height: 12),
          _summaryItem(
            icon: Icons.lightbulb_outline,
            iconColor: suggestion,
            title:
                "$clarityCount Clarity ${clarityCount == 1 ? 'Improvement' : 'Improvements'}",
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: const Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}
