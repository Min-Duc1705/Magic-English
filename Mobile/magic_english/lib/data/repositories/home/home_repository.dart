import 'package:magic_enlish/data/services/home_stats_service.dart';

class HomeRepository {
  final HomeStatsService _homeStatsService;

  HomeRepository({HomeStatsService? homeStatsService})
    : _homeStatsService = homeStatsService ?? HomeStatsService();

  /// Get home statistics
  /// Returns map with all home screen statistics
  /// Returns zero values if error occurs
  Future<Map<String, int>> getHomeStats() async {
    try {
      return await _homeStatsService.getHomeStats();
    } catch (e) {
      print('Repository error in getHomeStats: $e');
      return {
        'wordsToday': 0,
        'totalWords': 0,
        'streakDays': 0,
        'grammarChecks': 0,
        'totalChecks': 0,
        'avgGrammarScore': 0,
        'avgGrammarScoreTotal': 0,
        'longestStreak': 0,
      };
    }
  }

  /// Get words learned today
  Future<int> getWordsTodayCount() async {
    try {
      final stats = await getHomeStats();
      return stats['wordsToday'] ?? 0;
    } catch (e) {
      print('Repository error in getWordsTodayCount: $e');
      return 0;
    }
  }

  /// Get total words learned
  Future<int> getTotalWordsCount() async {
    try {
      final stats = await getHomeStats();
      return stats['totalWords'] ?? 0;
    } catch (e) {
      print('Repository error in getTotalWordsCount: $e');
      return 0;
    }
  }

  /// Get current study streak
  Future<int> getStreakDays() async {
    try {
      final stats = await getHomeStats();
      return stats['streakDays'] ?? 0;
    } catch (e) {
      print('Repository error in getStreakDays: $e');
      return 0;
    }
  }

  /// Get average grammar score
  Future<Map<String, int>> getGrammarStats() async {
    try {
      final stats = await getHomeStats();
      return {
        'grammarChecks': stats['grammarChecks'] ?? 0,
        'totalChecks': stats['totalChecks'] ?? 0,
        'avgGrammarScore': stats['avgGrammarScore'] ?? 0,
        'avgGrammarScoreTotal': stats['avgGrammarScoreTotal'] ?? 0,
      };
    } catch (e) {
      print('Repository error in getGrammarStats: $e');
      return {
        'grammarChecks': 0,
        'totalChecks': 0,
        'avgGrammarScore': 0,
        'avgGrammarScoreTotal': 0,
      };
    }
  }
}
