import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool visible;
  final VoidCallback onToggle;
  final Color inputBg;
  final Color borderLight;
  final Color placeholderLight;
  final Color primary;
  final String? Function(String?)? validator;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.hint,
    required this.visible,
    required this.onToggle,
    this.prefixIcon,
    this.inputBg = const Color(0xfff6f6f8),
    this.borderLight = const Color(0xffd3cfe7),
    this.placeholderLight = const Color(0xff594c9a),
    this.primary = const Color(0xff3713ec),
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: inputBg,
        hintText: hint,
        hintStyle: GoogleFonts.lexend(color: placeholderLight),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: placeholderLight)
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility : Icons.visibility_off,
            color: placeholderLight,
          ),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderLight),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
