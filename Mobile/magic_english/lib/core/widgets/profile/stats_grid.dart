import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:magic_enlish/core/widgets/progress/stat_card.dart';

class StatsGrid extends StatelessWidget {
  final int streakDays;
  final int wordsToday;
  final int masteredWords;
  final int quizScore;
  final int quizTotal;
  final List<String> cardTitles;
  final List<String> cardSubtitles;

  const StatsGrid({
    super.key,
    this.streakDays = 0,
    this.wordsToday = 0,
    this.masteredWords = 0,
    this.quizScore = 0,
    this.quizTotal = 100,
    required this.cardTitles,
    required this.cardSubtitles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon:
                    Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 25,
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 1500.ms,
                          color: Colors.yellow.shade700,
                        )
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.15, 1.15),
                          duration: 1000.ms,
                        ),
                iconColor: Colors.orange,
                title1: cardTitles[0],
                title2: cardSubtitles[0],
                value: "$streakDays Days",
                animated: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.menu_book,
                iconColor: Colors.blue,
                title1: cardTitles[1],
                title2: cardSubtitles[1],
                value: "$wordsToday Words",
                animated: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.psychology,
                iconColor: Colors.green,
                title1: cardTitles[2],
                title2: cardSubtitles[2],
                value: "${_formatNumber(masteredWords)} times",
                animated: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.star,
                iconColor: Colors.pinkAccent,
                title1: cardTitles[3],
                title2: cardSubtitles[3],
                value: "$quizScore/$quizTotal",
                animated: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}k";
    }
    return number.toString();
  }
}
