import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CefrLevelBadge extends StatelessWidget {
  final String level;
  final bool animated;
  final double fontSize;
  final EdgeInsets padding;

  const CefrLevelBadge({
    super.key,
    required this.level,
    this.animated = true,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: _buildBadge(value));
        },
      );
    }
    return _buildBadge(1.0);
  }

  Widget _buildBadge(double animationValue) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: _getCefrGradient(level),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: _getCefrColor(level).withOpacity(0.3 * animationValue),
            blurRadius: 4 * animationValue,
            offset: Offset(0, 2 * animationValue),
          ),
        ],
      ),
      child: Text(
        level,
        style: GoogleFonts.lexend(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCefrColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return const Color(0xFF4CAF50);
      case 'A2':
        return const Color(0xFF8BC34A);
      case 'B1':
        return const Color(0xFF2196F3);
      case 'B2':
        return const Color(0xFF3F51B5);
      case 'C1':
        return const Color(0xFFFF9800);
      case 'C2':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  LinearGradient _getCefrGradient(String level) {
    final color = _getCefrColor(level);
    return LinearGradient(
      colors: [color, color.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
