import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for IELTS Matching questions (Section 3)
/// Standard IELTS format:
/// - Options (lettered A-D): List of problems/reasons/opinions
/// - Objects (numbered 1-4): People/places with dropdowns to select option letter
class MatchingWidget extends StatelessWidget {
  final String questionText; // Instruction text
  final List<String> options; // Numbered options (problems, reasons, etc.)
  final List<MatchItem> items; // Lettered objects (people, places, etc.)
  final Map<int, String> selectedMatches; // itemIndex -> selected option
  final Function(int, String) onMatchSelected;

  const MatchingWidget({
    super.key,
    required this.questionText,
    required this.options,
    required this.items,
    required this.selectedMatches,
    required this.onMatchSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF333333);
    final textSecondary = isDark ? Colors.grey.shade300 : Colors.grey[800];
    final border = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final tealColor = isDark ? Colors.tealAccent : Colors.teal[700];
    final tealBg = isDark
        ? Colors.teal.withOpacity(0.2)
        : Colors.teal.withOpacity(0.08);
    final tealBorder = isDark
        ? Colors.teal.withOpacity(0.4)
        : Colors.teal.withOpacity(0.3);
    final objectsBg = isDark ? const Color(0xFF2C2C2C) : Colors.grey[50];
    final objectsBorder = isDark ? Colors.grey.shade700 : Colors.grey[200];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.compare_arrows, color: tealColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Matching',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: tealColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Instruction text
          Text(
            questionText,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // OPTIONS SECTION (numbered 1, 2, 3... - light background)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tealBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tealBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Options:',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: tealColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...options.asMap().entries.map((entry) {
                  final letter = String.fromCharCode(
                    65 + entry.key,
                  ); // A, B, C, D
                  // Remove number/letter prefix if exists (e.g., "1. Survey" -> "Survey")
                  String text = entry.value;
                  if (text.length > 2 && text[1] == '.') {
                    text = text.substring(2).trim();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          child: Text(
                            '$letter.',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tealColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            text,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // OBJECTS SECTION (lettered A, B, C... with dropdowns)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: objectsBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: objectsBorder!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match:',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade400 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final number = index + 1; // 1, 2, 3, 4...
                  final selected = selectedMatches[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        // Number label
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.teal[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '$number',
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.tealAccent
                                    : Colors.teal[800],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Item name
                        Expanded(
                          child: Text(
                            item.text,
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ),
                        // Arrow
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        // Dropdown for selecting option number
                        Container(
                          width: 60,
                          height: 36,
                          decoration: BoxDecoration(
                            color: selected != null
                                ? (isDark
                                      ? Colors.teal.withOpacity(0.3)
                                      : Colors.teal.withOpacity(0.15))
                                : (isDark
                                      ? Colors.grey.shade800
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: selected != null
                                  ? (isDark ? Colors.tealAccent : Colors.teal)
                                  : (isDark
                                        ? Colors.grey.shade600
                                        : Colors.grey[300]!),
                              width: selected != null ? 2 : 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selected,
                              isExpanded: true,
                              hint: Center(
                                child: Text(
                                  '?',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey[400],
                                  ),
                                ),
                              ),
                              // Show only letter when selected
                              selectedItemBuilder: (context) {
                                return options.asMap().entries.map((e) {
                                  return Center(
                                    child: Text(
                                      String.fromCharCode(
                                        65 + e.key,
                                      ), // A, B, C, D
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal[700],
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              items: options.asMap().entries.map((e) {
                                final letter = String.fromCharCode(
                                  65 + e.key,
                                ); // A, B, C, D
                                return DropdownMenuItem<String>(
                                  value: e.value,
                                  child: Center(
                                    child: Text(
                                      letter,
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal[700],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  onMatchSelected(index, value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MatchItem {
  final int id;
  final String text;

  MatchItem({required this.id, required this.text});
}
