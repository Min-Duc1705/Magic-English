import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/vocabulary/cefr_level_badge.dart';
import 'package:magic_enlish/core/widgets/vocabulary/example_item_widget.dart';

class VocabularyInfoSection extends StatelessWidget {
  final String meaning;
  final String wordType;
  final String cefrLevel;
  final String examples;
  final Color primaryColor;

  const VocabularyInfoSection({
    super.key,
    required this.meaning,
    required this.wordType,
    required this.cefrLevel,
    required this.examples,
    this.primaryColor = const Color(0xFF4A90E2),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meaning Section
        Text(
          "Meaning",
          style: GoogleFonts.lexend(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          meaning,
          style: GoogleFonts.lexend(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 22),

        // Word Type and CEFR Level
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Word Type",
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wordType,
                    style: GoogleFonts.lexend(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CEFR Level",
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CefrLevelBadge(
                    level: cefrLevel,
                    animated: false,
                    fontSize: 13,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Examples Section
        Text(
          "Example",
          style: GoogleFonts.lexend(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...examples
            .split('\n')
            .where((e) => e.isNotEmpty)
            .map((e) => ExampleItem(text: e, iconColor: primaryColor)),
      ],
    );
  }
}
