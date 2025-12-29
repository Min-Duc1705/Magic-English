import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VocabularyWordSection extends StatelessWidget {
  final String word;
  final String ipa;
  final bool isPlaying;
  final VoidCallback onAudioTap;
  final Animation<double> animation;
  final Color primaryColor;

  const VocabularyWordSection({
    super.key,
    required this.word,
    required this.ipa,
    required this.isPlaying,
    required this.onAudioTap,
    required this.animation,
    this.primaryColor = const Color(0xFF4A90E2),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word,
                style: GoogleFonts.lexend(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ipa,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onAudioTap,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? primaryColor.withOpacity(0.2)
                      : primaryColor.withOpacity(.12),
                  shape: BoxShape.circle,
                  boxShadow: isPlaying
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(
                              0.3 * animation.value,
                            ),
                            blurRadius: 10 + (10 * animation.value),
                            spreadRadius: animation.value * 5,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.volume_up,
                  size: 28,
                  color: primaryColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
