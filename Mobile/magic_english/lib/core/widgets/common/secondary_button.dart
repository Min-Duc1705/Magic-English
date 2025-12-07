import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color primaryColor;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.primaryColor = const Color(0xFF4A90E2),
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: primaryColor.withOpacity(0.3)),
        backgroundColor: primaryColor.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        minimumSize: const Size(80, 40),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.lexend(color: primaryColor, fontSize: 14),
      ),
    );
  }
}
