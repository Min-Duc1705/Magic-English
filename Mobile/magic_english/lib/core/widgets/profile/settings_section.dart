import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final List<Widget> items;
  const SettingsSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 6),
          ],
        ),
        child: Column(children: items),
      ),
    );
  }
}
