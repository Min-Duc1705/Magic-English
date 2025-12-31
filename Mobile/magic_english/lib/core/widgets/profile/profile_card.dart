import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;
  final VoidCallback? onEdit;

  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final editBgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final editIconColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(.2)
                : Colors.black.withOpacity(.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 96,
            width: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(avatarUrl),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: editBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, size: 20, color: editIconColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.lexend(fontSize: 13, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}
