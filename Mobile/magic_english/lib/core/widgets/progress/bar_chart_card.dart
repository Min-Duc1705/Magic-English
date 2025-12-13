import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/models/progress/progress_data.dart';

class BarChartCard extends StatelessWidget {
  final CefrDistribution distribution;

  const BarChartCard({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    const cardBg = Colors.white;
    const borderColor = Color(0xFFE0E0E0);
    const textColor = Color(0xFF100d1b);
    const primary = Color(0xFF4A90E2);

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
            'CEFR Level Distribution',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _barChart(
                  'A1',
                  distribution.a1,
                  distribution.getNormalizedHeight(distribution.a1),
                  primary.withOpacity(0.2),
                ),
                _barChart(
                  'A2',
                  distribution.a2,
                  distribution.getNormalizedHeight(distribution.a2),
                  primary.withOpacity(0.2),
                ),
                _barChart(
                  'B1',
                  distribution.b1,
                  distribution.getNormalizedHeight(distribution.b1),
                  primary,
                ),
                _barChart(
                  'B2',
                  distribution.b2,
                  distribution.getNormalizedHeight(distribution.b2),
                  primary.withOpacity(0.2),
                ),
                _barChart(
                  'C1',
                  distribution.c1,
                  distribution.getNormalizedHeight(distribution.c1),
                  primary.withOpacity(0.2),
                ),
                _barChart(
                  'C2',
                  distribution.c2,
                  distribution.getNormalizedHeight(distribution.c2),
                  primary.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barChart(String label, int count, double height, Color color) {
    const textMuted = Color(0xFF888888);
    const textColor = Color(0xFF100d1b);
    // Minimum height for empty bars
    final barHeight = height == 0 ? 10.0 : 120 * height;
    final barColor = height == 0 ? Colors.grey.shade300 : color;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Count number on top
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                count.toString(),
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          // Bar
          Flexible(
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Level label
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
