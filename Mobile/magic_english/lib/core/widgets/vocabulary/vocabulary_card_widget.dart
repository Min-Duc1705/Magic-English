import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/vocabulary/cefr_level_badge.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';
import 'package:magic_enlish/features/vocabulary/review_word_screen.dart';

class VocabularyCardWidget extends StatelessWidget {
  final Vocabulary vocabulary;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onTap;
  final Color primaryColor;

  const VocabularyCardWidget({
    super.key,
    required this.vocabulary,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onMoreTap,
    this.onTap,
    this.primaryColor = const Color(0xFF4A90E2),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VocabularyDetailScreen(vocabulary: vocabulary),
              ),
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 6),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MAIN TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        vocabulary.word,
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vocabulary.wordType.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(${vocabulary.wordType})',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vocabulary.meaning,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CefrLevelBadge(level: vocabulary.cefrLevel),
                      if (vocabulary.ipa.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          vocabulary.ipa,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontFamily: 'serif',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // FAVORITE + MORE
            Column(
              children: [
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onMoreTap,
                  child: Icon(Icons.more_vert, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
