import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';
import 'package:magic_enlish/data/models/progress/achievement.dart';
import 'package:magic_enlish/providers/progress/progress_provider.dart';
import 'package:provider/provider.dart';

class AllAchievementsScreen extends StatelessWidget {
  const AllAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF60A5FA) : const Color(0xFF4A90E2);
    final background = isDark
        ? const Color(0xFF18181B)
        : const Color(0xFFF9F9F9);
    final surface = isDark ? const Color(0xFF27272A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF100d1b);
    final textMuted = isDark ? Colors.grey.shade400 : const Color(0xFF888888);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Achievements',
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          final allAchievements = progressProvider.allAchievements;
          final unlockedIds = progressProvider.unlockedAchievementIds;

          // Separate unlocked and locked achievements
          final unlockedAchievements = allAchievements
              .where((a) => unlockedIds.contains(a.id))
              .toList();
          final lockedAchievements = allAchievements
              .where((a) => !unlockedIds.contains(a.id))
              .toList();

          if (allAchievements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No achievements available',
                    style: GoogleFonts.lexend(fontSize: 16, color: textMuted),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Summary Card
                _buildStatsSummaryCard(
                  unlockedCount: unlockedAchievements.length,
                  totalCount: allAchievements.length,
                  primary: primary,
                  textColor: textColor,
                ),
                const SizedBox(height: 24),

                // Unlocked Achievements Section
                if (unlockedAchievements.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Unlocked',
                    icon: Icons.check_circle,
                    iconColor: const Color(0xFF2E7D32),
                    count: unlockedAchievements.length,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  _buildAchievementsGrid(
                    achievements: unlockedAchievements,
                    isLocked: false,
                    textColor: textColor,
                    textMuted: textMuted,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                ],

                // Locked Achievements Section
                if (lockedAchievements.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Locked',
                    icon: Icons.lock_outline,
                    iconColor: Colors.grey.shade600,
                    count: lockedAchievements.length,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  _buildAchievementsGrid(
                    achievements: lockedAchievements,
                    isLocked: true,
                    textColor: textColor,
                    textMuted: textMuted,
                    isDark: isDark,
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSummaryCard({
    required int unlockedCount,
    required int totalCount,
    required Color primary,
    required Color textColor,
  }) {
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress Circle
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Stats Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achievement Progress',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$unlockedCount / $totalCount Unlocked',
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unlockedCount == totalCount
                      ? 'Congratulations! All unlocked!'
                      : 'Keep learning to unlock more!',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
    required int count,
    required Color textColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid({
    required List<Achievement> achievements,
    required bool isLocked,
    required Color textColor,
    required Color textMuted,
    required bool isDark,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(
          achievement: achievements[index],
          isLocked: isLocked,
          textColor: textColor,
          textMuted: textMuted,
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildAchievementCard({
    required Achievement achievement,
    required bool isLocked,
    required Color textColor,
    required Color textMuted,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? (isDark ? Colors.grey.shade700 : Colors.grey.shade200)
              : const Color(0xFF2E7D32).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isLocked
                ? Colors.transparent
                : Colors.green.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 70,
            height: 70,
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
                child: _buildAchievementIcon(achievement, isLocked, isDark),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            isLocked ? 'Locked' : achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isLocked ? textMuted : textColor,
            ),
          ),
          const SizedBox(height: 4),

          // Requirement
          Text(
            isLocked
                ? '${achievement.requiredValue} ${_getMetricLabel(achievement.metricType)} required'
                : '${achievement.requiredValue} ${_getMetricLabel(achievement.metricType)}',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(fontSize: 11, color: textMuted),
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

  Widget _buildAchievementIcon(
    Achievement achievement,
    bool isLocked,
    bool isDark,
  ) {
    if (isLocked) {
      return SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.emoji_events, size: 40, color: Colors.amber.shade600),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
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
                child: Icon(Icons.lock, size: 12, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      );
    }

    if (achievement.iconUrl.isNotEmpty) {
      String fullUrl = BackendUtils.getFullUrl(
        achievement.iconUrl.startsWith('http')
            ? achievement.iconUrl
            : '/storage/achievement/${achievement.iconUrl}',
      );

      return Image.network(
        fullUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.emoji_events, size: 36, color: Colors.amber);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.amber.shade300,
              ),
            ),
          );
        },
      );
    }

    return Icon(Icons.emoji_events, size: 36, color: Colors.amber);
  }
}
