import 'package:flutter/material.dart';
import 'package:magic_enlish/core/widgets/home/action_card.dart';
import 'package:magic_enlish/core/widgets/common/primary_button.dart';
import 'package:magic_enlish/core/widgets/common/secondary_button.dart';

class ActionCardsSection extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback? onAddNewWord;
  final VoidCallback? onReviewWords;
  final VoidCallback? onCheckText;
  final VoidCallback? onViewProgress;

  const ActionCardsSection({
    super.key,
    required this.primaryColor,
    this.onAddNewWord,
    this.onReviewWords,
    this.onCheckText,
    this.onViewProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActionCard(
          icon: Icons.translate,
          iconColor: primaryColor,
          title: "Magic Vocab",
          subtitle: "Build and review your personal dictionary.",
          buttons: [
            PrimaryButton(
              text: "Add New Word",
              onPressed: onAddNewWord ?? () {},
            ),
            SecondaryButton(
              text: "Review Words",
              onPressed: onReviewWords ?? () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        ActionCard(
          icon: Icons.edit_note,
          iconColor: primaryColor,
          title: "Grammar & Style",
          subtitle: "Refine your writing with AI.",
          buttons: [
            PrimaryButton(text: "Check Text", onPressed: onCheckText ?? () {}),
          ],
        ),
        const SizedBox(height: 12),
        ActionCard(
          icon: Icons.monitor_heart,
          iconColor: primaryColor,
          title: "Progress Dashboard",
          subtitle: "Track your learning journey.",
          buttons: [
            PrimaryButton(
              text: "View Progress",
              onPressed: onViewProgress ?? () {},
            ),
          ],
        ),
      ],
    );
  }
}
