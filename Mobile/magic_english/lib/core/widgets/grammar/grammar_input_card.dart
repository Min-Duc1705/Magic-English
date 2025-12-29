import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrammarInputCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCheck;
  final bool isLoading;

  const GrammarInputCard({
    super.key,
    required this.controller,
    required this.onCheck,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF3D3D3D)
        : const Color(0xFFEAECEF);
    const Color primary = Color(0xFF4A90E2);
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final hintColor = isDark
        ? Colors.grey.shade500
        : const Color(0xFF333333).withOpacity(0.5);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              TextField(
                controller: controller,
                maxLines: 6,
                maxLength: 5000,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Type or paste your text here...",
                  hintStyle: GoogleFonts.lexend(color: hintColor, fontSize: 16),
                  counterText: "",
                  contentPadding: EdgeInsets.zero,
                ),
                style: GoogleFonts.lexend(fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${controller.text.length}/5000",
                  style: GoogleFonts.lexend(
                    color: textColor.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : onCheck,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              disabledBackgroundColor: primary.withOpacity(0.6),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    "Check Grammar",
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
