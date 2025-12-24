import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? rightAction;

  const AppTopBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.rightAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 28),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          rightAction ?? const SizedBox(width: 28),
        ],
      ),
    );
  }
}
