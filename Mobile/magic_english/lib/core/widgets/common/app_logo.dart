import 'package:flutter/material.dart';
import 'package:magic_enlish/core/theme/app_colors.dart';
import 'package:magic_enlish/core/theme/app_text_styles.dart';

class AppLogo extends StatelessWidget {
  final bool showTitle;
  final double size;

  const AppLogo({super.key, this.showTitle = true, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size / 4),
          ),
          child: Icon(
            Icons.auto_stories,
            size: size * 0.6,
            color: Colors.white,
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: 16),
          Text("Magic English", style: AppTextStyles.appTitle()),
        ],
      ],
    );
  }
}
