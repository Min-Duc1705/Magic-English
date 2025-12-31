import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';
import 'package:magic_enlish/core/widgets/progress/donut_chart_card.dart';
import 'package:magic_enlish/core/widgets/progress/bar_chart_card.dart';
import 'package:magic_enlish/core/widgets/profile/stats_grid.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';
import 'package:magic_enlish/data/models/progress/achievement.dart';
import 'package:magic_enlish/features/progress/all_achievements_screen.dart';
import 'package:magic_enlish/features/progress/streak_detail_screen.dart';
import 'package:magic_enlish/features/progress/vocabulary_detail_screen.dart';
import 'package:magic_enlish/features/progress/grammar_check_detail_screen.dart';
import 'package:magic_enlish/features/progress/grammar_score_detail_screen.dart';
import 'package:magic_enlish/providers/progress/progress_provider.dart';
import 'package:magic_enlish/providers/auth/auth_provider.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF18181B)
        : const Color(0xFFF9F9F9);
    final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF100d1b);

    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: cardColor,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final user = authProvider.user;
                          String? avatarUrl;
                          if (user?.avatarUrl != null &&
                              user!.avatarUrl!.isNotEmpty) {
                            if (user.avatarUrl!.startsWith('http')) {
                              avatarUrl = user.avatarUrl;
                            } else {
                              avatarUrl = BackendUtils.getFullUrl(
                                '/storage/avatar/${user.avatarUrl}',
                              );
                            }
                          }

                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF3F3F46)
                                  : Colors.grey.shade200,
                            ),
                            child: ClipOval(
                              child: avatarUrl != null
                                  ? Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.person,
                                            size: 24,
                                            color: isDark
                                                ? Colors.grey.shade300
                                                : Colors.grey,
                                          ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 24,
                                      color: isDark
                                          ? Colors.grey.shade300
                                          : Colors.grey,
                                    ),
                            ),
                          );
                        },
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

                                const SizedBox(height: 8),

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Achievements',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllAchievementsScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF4A90E2),
                  ),
                ],
              ),
            ),
          ],
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
      onStreakTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StreakDetailScreen(
              currentStreak: progressProvider.longestStreak,
            ),
          ),
        );
      },
      onVocabularyTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VocabularyDetailScreen(
              totalWords: progressProvider.totalVocabularyCount,
            ),
          ),
        );
      },
      onGrammarCheckTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrammarCheckDetailScreen(
              totalChecks: progressProvider.totalGrammarChecks,
            ),
          ),
        );
      },
      onGrammarScoreTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrammarScoreDetailScreen(
              avgScore: progressProvider.avgGrammarScoreTotal,
            ),
          ),
        );
      },
    );
  }

  Widget _achievementBadge({
    required Achievement achievement,
    required bool isLocked,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF100d1b);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF888888);

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
              color: isDark ? const Color(0xFF27272A) : Colors.white,
              border: Border.all(
                color: isLocked
                    ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
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
                color: isDark ? const Color(0xFF27272A) : Colors.white,
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
              color: isLocked
                  ? (isDark ? Colors.grey.shade500 : textMuted)
                  : textColor,
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
    // If locked, show cup with lock overlay
    if (isLocked) {
      return SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cup icon with amber/gold color
            Icon(Icons.emoji_events, size: 56, color: Colors.amber.shade600),
            // Lock badge at bottom right
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF27272A)
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade600
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(Icons.lock, size: 14, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      );
    }

    // If has iconUrl, try to load image
    if (achievement.iconUrl.isNotEmpty) {
      // Use BackendUtils to handle both relative and absolute URLs
      String fullUrl = BackendUtils.getFullUrl(
        achievement.iconUrl.startsWith('http')
            ? achievement.iconUrl
            : '/storage/achievement/${achievement.iconUrl}',
      );

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
