import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExampleItem extends StatelessWidget {
  final String text;
  final Color iconColor;

  const ExampleItem({
    super.key,
    required this.text,
    this.iconColor = const Color(0xff3713ec),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote, size: 20, color: iconColor.withOpacity(.9)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lexend(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
