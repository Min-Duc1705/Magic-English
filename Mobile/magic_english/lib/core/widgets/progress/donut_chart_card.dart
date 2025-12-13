import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/models/progress/progress_data.dart';
import 'dart:math' as math;

class DonutChartCard extends StatelessWidget {
  final VocabularyBreakdown breakdown;

  const DonutChartCard({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    const cardBg = Colors.white;
    const borderColor = Color(0xFFE0E0E0);
    const textColor = Color(0xFF100d1b);
    const textMuted = Color(0xFF888888);
    const primary = Color(0xFF4A90E2);
    const secondary = Color(0xFF50E3C2);
    const accent = Color(0xFFF8D648);
    const purple = Color(0xFF8884d8);

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
                      painter: DonutChartPainter(breakdown: breakdown),
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
                    ),
                    _legendItem(
                      'Adjectives (${(breakdown.getPercentage(breakdown.adjective) * 100).toStringAsFixed(0)}%)',
                      secondary,
                    ),
                    _legendItem(
                      'Nouns (${(breakdown.getPercentage(breakdown.noun) * 100).toStringAsFixed(0)}%)',
                      accent,
                    ),
                    _legendItem(
                      'Adverbs (${(breakdown.getPercentage(breakdown.adverb) * 100).toStringAsFixed(0)}%)',
                      purple,
                    ),
                    if (breakdown.other > 0)
                      _legendItem(
                        'Other (${(breakdown.getPercentage(breakdown.other) * 100).toStringAsFixed(0)}%)',
                        Colors.grey,
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

  Widget _legendItem(String label, Color color) {
    const textColor = Color(0xFF100d1b);

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

  DonutChartPainter({required this.breakdown});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;

    const primary = Color(0xFF4A90E2);
    const secondary = Color(0xFF50E3C2);
    const accent = Color(0xFFF8D648);
    const purple = Color(0xFF8884d8);

    // If no data, draw empty gray circle
    if (breakdown.total == 0) {
      final paint = Paint()
        ..color = Colors.grey.shade300
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
