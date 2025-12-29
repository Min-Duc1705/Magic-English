import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WordInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final VoidCallback? onMicTap;
  final ValueChanged<String>? onChanged;
  final Color primaryColor;
  final Color secondaryColor;

  const WordInputField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.hintText = 'e.g., serendipity',
    this.labelText,
    this.helperText,
    this.errorText,
    this.onMicTap,
    this.onChanged,
    this.primaryColor = const Color(0xFF3A57E8),
    this.secondaryColor = const Color(0xFF00C49A),
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasError ? Colors.red : Colors.grey.shade300,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                onChanged: onChanged,
                enableIMEPersonalizedLearning: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  hintText: hintText,
                  hintStyle: GoogleFonts.lexend(
                    color: const Color(0xFFADB5BD),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (onMicTap != null)
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: enabled ? onMicTap : null,
                  child: Icon(
                    Icons.mic,
                    color: enabled ? secondaryColor : Colors.grey,
                    size: 28,
                  ),
                ),
              ),
          ],
        ),
        // Error text (takes priority over helper text)
        if (hasError) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: Colors.red),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  errorText!,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 10),
          Text(
            helperText!,
            style: GoogleFonts.lexend(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}
