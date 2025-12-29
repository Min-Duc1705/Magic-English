import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final List<Widget> items;
  const SettingsSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(.2)
                  : Colors.black.withOpacity(.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(children: items),
      ),
    );
  }
}
