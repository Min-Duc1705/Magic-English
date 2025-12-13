import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';
import 'package:magic_enlish/core/widgets/progress/donut_chart_card.dart';
import 'package:magic_enlish/core/widgets/progress/bar_chart_card.dart';
import 'package:magic_enlish/core/widgets/profile/stats_grid.dart';
import 'package:magic_enlish/core/constants/api_constants.dart';
import 'package:magic_enlish/data/models/progress/achievement.dart';
import 'package:magic_enlish/providers/progress/progress_provider.dart';
import 'package:provider/provider.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().loadProgressData();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4A90E2);
    const accent = Color(0xFFF8D648);
    const background = Color(0xFFF9F9F9);
    const textColor = Color(0xFF100d1b);

    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: const Icon(Icons.person, size: 24),
                      ),
                      Expanded(
                        child: Text(
                          'My Progress',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: textColor,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: progressProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : progressProvider.errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load progress data',
                                style: GoogleFonts.lexend(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    progressProvider.refreshProgressData(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              progressProvider.refreshProgressData(),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats Grid (reusing StatsGrid component)
                                _buildStatsGrid(
                                  progressProvider,
                                  accent,
                                  primary,
                                ),

                                const SizedBox(height: 24),

                                // Achievements Section (dynamic from API)
                                _buildAchievementsSection(
                                  textColor,
                                  progressProvider,
                                ),

                                const SizedBox(height: 24),

                                // Vocabulary Breakdown
                                if (progressProvider.vocabularyBreakdown !=
                                    null)
                                  DonutChartCard(
                                    breakdown:
                                        progressProvider.vocabularyBreakdown!,
                                  ),

                                const SizedBox(height: 16),

                                // CEFR Level Distribution
                                if (progressProvider.cefrDistribution != null)
                                  BarChartCard(
                                    distribution:
                                        progressProvider.cefrDistribution!,
                                  ),

                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNav(currentIndex: 3),
        );
      },
    );
  }

  Widget _buildAchievementsSection(
    Color textColor,
    ProgressProvider progressProvider,
  ) {
    final allAchievements = progressProvider.allAchievements;
    final unlockedIds = progressProvider.unlockedAchievementIds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Achievements',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: allAchievements.isEmpty
              ? Center(
                  child: Text(
                    'No achievements available',
                    style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: allAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = allAchievements[index];
                    final isUnlocked = unlockedIds.contains(achievement.id);
                    return _achievementBadge(
                      achievement: achievement,
                      isLocked: !isUnlocked,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    ProgressProvider progressProvider,
    Color accent,
    Color primary,
  ) {
    return StatsGrid(
      streakDays: progressProvider.longestStreak,
      wordsToday: progressProvider.totalVocabularyCount,
      masteredWords: progressProvider.totalGrammarChecks,
      quizScore: progressProvider.avgGrammarScoreTotal,
      quizTotal: 100,
      cardTitles: const [
        'Longest',
        'Vocabulary',
        'Grammar Check',
        'Grammar Score',
      ],
      cardSubtitles: const ['Streak', 'Total', 'Total', 'Avg Total'],
    );
  }

  Widget _achievementBadge({
    required Achievement achievement,
    required bool isLocked,
  }) {
    const textColor = Color(0xFF100d1b);
    const textMuted = Color(0xFF888888);

    return Container(
      width: 112,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isLocked
                    ? Colors.grey.shade300
                    : const Color(0xFF2E7D32),
                width: 2,
              ),
              boxShadow: isLocked
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipOval(
              child: Container(
                color: Colors.white,
                child: _buildAchievementIcon(achievement, isLocked),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLocked ? 'Locked' : achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isLocked ? textMuted : textColor,
            ),
          ),
          Text(
            isLocked
                ? 'Keep going!'
                : '${achievement.requiredValue} ${_getMetricLabel(achievement.metricType)}',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(fontSize: 12, color: textMuted),
          ),
        ],
      ),
    );
  }

  String _getMetricLabel(String metricType) {
    switch (metricType) {
      case 'vocab_added':
        return 'words';
      case 'grammar_check':
        return 'checks';
      case 'learning_streak':
        return 'days';
      default:
        return '';
    }
  }

  Widget _buildAchievementIcon(Achievement achievement, bool isLocked) {
    // If locked, show lock icon
    if (isLocked) {
      return Icon(Icons.lock, size: 36, color: Colors.grey.shade400);
    }

    // If has iconUrl, try to load image
    if (achievement.iconUrl.isNotEmpty) {
      String fullUrl = achievement.iconUrl;
      // Build full URL if iconUrl is just a filename
      if (!achievement.iconUrl.startsWith('http')) {
        String baseUrl = ApiConstants.baseUrl.replaceAll('/api/v1', '');
        fullUrl = '$baseUrl/storage/achievement/${achievement.iconUrl}';
      }

      return Image.network(
        fullUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.emoji_events, size: 40, color: Colors.amber);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.amber.shade300,
              ),
            ),
          );
        },
      );
    }

    // Default icon
    return Icon(Icons.emoji_events, size: 40, color: Colors.amber);
  }
}
