import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WordCard extends StatelessWidget {
  final String word;
  final String meaning;
  final VoidCallback? onSpeakPressed;

  const WordCard({
    super.key,
    required this.word,
    required this.meaning,
    this.onSpeakPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  meaning,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 26),
            onPressed: onSpeakPressed ?? () {},
          ),
        ],
      ),
    );
  }
}
