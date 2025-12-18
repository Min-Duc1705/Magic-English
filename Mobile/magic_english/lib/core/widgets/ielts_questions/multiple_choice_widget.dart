import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for IELTS Multiple Choice questions (Section 2, 3)
/// Supports multi-select (2-3 correct answers)
class MultipleChoiceWidget extends StatelessWidget {
  final String questionText;
  final List<AnswerOption> options;
  final Set<int> selectedIndices;
  final Function(int) onOptionToggled;

  const MultipleChoiceWidget({
    super.key,
    required this.questionText,
    required this.options,
    required this.selectedIndices,
    required this.onOptionToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.check_box_outlined,
                color: const Color(0xFF4A90E2),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Multiple Choice',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A90E2),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Select 1 or more',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question text
          Text(
            questionText,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: const Color(0xFF333333),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Options
          ...List.generate(options.length, (index) {
            final option = options[index];
            final isSelected = selectedIndices.contains(index);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onOptionToggled(index),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4A90E2).withOpacity(0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4A90E2)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Checkbox style indicator
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4A90E2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4A90E2)
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Option letter (A, B, C, D, E)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4A90E2)
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            option.label,
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Option text
                      Expanded(
                        child: Text(
                          option.text,
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            color: const Color(0xFF333333),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Selected count indicator
          if (selectedIndices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${selectedIndices.length} answer${selectedIndices.length > 1 ? 's' : ''} selected',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  color:
                      selectedIndices.length >= 1 && selectedIndices.length <= 3
                      ? Colors.green[600]
                      : Colors.orange[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AnswerOption {
  final String label; // A, B, C, D, E
  final String text;
  final int id;

  AnswerOption({required this.label, required this.text, required this.id});
}
