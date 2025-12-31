import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/models/progress/progress_data.dart';
import 'dart:math' as math;

class DonutChartCard extends StatelessWidget {
  final VocabularyBreakdown breakdown;

  const DonutChartCard({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF3D3D3D)
        : const Color(0xFFE0E0E0);
    final textColor = isDark ? Colors.white : const Color(0xFF100d1b);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF888888);
    final primary = isDark ? const Color(0xFF60A5FA) : const Color(0xFF4A90E2);
    final secondary = isDark
        ? const Color(0xFF2DD4BF)
        : const Color(0xFF50E3C2);
    final accent = isDark ? const Color(0xFFFACC15) : const Color(0xFFF8D648);
    final purple = isDark ? const Color(0xFFA78BFA) : const Color(0xFF8884d8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vocabulary Breakdown',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: DonutChartPainter(
                        breakdown: breakdown,
                        emptyColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                        primary: primary,
                        secondary: secondary,
                        accent: accent,
                        purple: purple,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          breakdown.total.toString(),
                          style: GoogleFonts.lexend(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Words',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _legendItem(
                      'Verbs (${(breakdown.getPercentage(breakdown.verb) * 100).toStringAsFixed(0)}%)',
                      primary,
                      isDark,
                    ),
                    _legendItem(
                      'Adjectives (${(breakdown.getPercentage(breakdown.adjective) * 100).toStringAsFixed(0)}%)',
                      secondary,
                      isDark,
                    ),
                    _legendItem(
                      'Nouns (${(breakdown.getPercentage(breakdown.noun) * 100).toStringAsFixed(0)}%)',
                      accent,
                      isDark,
                    ),
                    _legendItem(
                      'Adverbs (${(breakdown.getPercentage(breakdown.adverb) * 100).toStringAsFixed(0)}%)',
                      purple,
                      isDark,
                    ),
                    if (breakdown.other > 0)
                      _legendItem(
                        'Other (${(breakdown.getPercentage(breakdown.other) * 100).toStringAsFixed(0)}%)',
                        isDark ? Colors.grey.shade600 : Colors.grey,
                        isDark,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF100d1b);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.lexend(fontSize: 14, color: textColor)),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final VocabularyBreakdown breakdown;
  final Color emptyColor;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color purple;

  DonutChartPainter({
    required this.breakdown,
    required this.emptyColor,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.purple,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;

    // If no data, draw empty circle
    if (breakdown.total == 0) {
      final paint = Paint()
        ..color = emptyColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        0,
        2 * math.pi,
        false,
        paint,
      );
      return;
    }

    final segments = [
      {'color': primary, 'percentage': breakdown.getPercentage(breakdown.verb)},
      {
        'color': secondary,
        'percentage': breakdown.getPercentage(breakdown.adjective),
      },
      {'color': accent, 'percentage': breakdown.getPercentage(breakdown.noun)},
      {
        'color': purple,
        'percentage': breakdown.getPercentage(breakdown.adverb),
      },
      if (breakdown.other > 0)
        {
          'color': Colors.grey,
          'percentage': breakdown.getPercentage(breakdown.other),
        },
    ];

    double startAngle = -math.pi / 2;

    for (var segment in segments) {
      final sweepAngle = 2 * math.pi * (segment['percentage'] as double);
      if (sweepAngle > 0) {
        final paint = Paint()
          ..color = segment['color'] as Color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
          startAngle,
          sweepAngle,
          false,
          paint,
        );

        startAngle += sweepAngle;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
