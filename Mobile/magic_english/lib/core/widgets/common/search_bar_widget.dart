import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    this.hintText = "Search...",
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final hintColor = isDark ? Colors.grey.shade500 : Colors.grey.shade500;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(.2)
                : Colors.black.withOpacity(.06),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              enableIMEPersonalizedLearning: true,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: hintColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
