import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/models/grammar/grammar_error.dart';

class GrammarErrorCard extends StatelessWidget {
  final GrammarError error;

  const GrammarErrorCard({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Colors.white;
    const Color borderColor = Color(0xFFEAECEF);
    const Color success = Color(0xFF7ED321);

    final errorTypeInfo = _getErrorTypeInfo(error.errorType);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                errorTypeInfo['icon'],
                size: 16,
                color: errorTypeInfo['color'],
              ),
              const SizedBox(width: 8),
              Text(
                error.errorType.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: errorTypeInfo['color'],
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: GoogleFonts.lexend(
                fontSize: 16,
                color: const Color(0xFF333333),
              ),
              children: [
                TextSpan(text: error.beforeText),
                if (error.errorText.isNotEmpty)
                  TextSpan(
                    text: error.errorText,
                    style: TextStyle(
                      color: errorTypeInfo['color'],
                      backgroundColor: (errorTypeInfo['color'] as Color)
                          .withOpacity(0.1),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                if (error.correctedText.isNotEmpty)
                  TextSpan(
                    text: error.correctedText,
                    style: TextStyle(
                      color: success,
                      backgroundColor: success.withOpacity(0.1),
                    ),
                  ),
                TextSpan(text: error.afterText),
              ],
            ),
          ),
          if (error.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              error.explanation,
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: const Color(0xFF333333).withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _getErrorTypeInfo(String type) {
    switch (type.toLowerCase()) {
      case 'spelling':
        return {'icon': Icons.spellcheck, 'color': const Color(0xFFE94E77)};
      case 'punctuation':
        return {'icon': Icons.edit, 'color': const Color(0xFF4A90E2)};
      case 'clarity':
        return {
          'icon': Icons.lightbulb_outline,
          'color': const Color(0xFFF5A623),
        };
      case 'grammar':
      default:
        return {'icon': Icons.text_fields, 'color': const Color(0xFF9B59B6)};
    }
  }
}
