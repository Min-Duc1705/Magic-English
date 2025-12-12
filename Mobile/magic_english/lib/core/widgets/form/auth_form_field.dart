import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthFormField extends StatelessWidget {
  final String label;
  final Widget inputWidget;

  const AuthFormField({
    super.key,
    required this.label,
    required this.inputWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        inputWidget,
      ],
    );
  }
}
