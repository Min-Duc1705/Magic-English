import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;
  final Color primaryColor;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
    this.primaryColor = const Color(0xff3713ec),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : chipBg,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? []
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(.2)
                        : Colors.black.withOpacity(.05),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.white : Colors.yellow.shade600,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.lexend(
                color: isActive ? Colors.white : textColor,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
