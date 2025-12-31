import 'package:magic_enlish/data/services/progress_service.dart';

class ProgressRepository {
  final ProgressService _progressService;

  ProgressRepository({ProgressService? progressService})
    : _progressService = progressService ?? ProgressService();

  /// Get vocabulary breakdown by word type
  /// Returns map with counts for each word type (verb, noun, adjective, adverb)
  /// Returns zero values if error occurs
  Future<Map<String, int>> getVocabularyBreakdown() async {
    try {
      return await _progressService.getVocabularyBreakdown();
    } catch (e) {
      print('Repository error in getVocabularyBreakdown: $e');
      return {'verb': 0, 'noun': 0, 'adjective': 0, 'adverb': 0, 'other': 0};
    }
  }

  /// Get CEFR level distribution (A1-C2)
  /// Returns map with counts for each CEFR level
  /// Returns zero values if error occurs
  Future<Map<String, int>> getCefrLevelDistribution() async {
    try {
      return await _progressService.getCefrDistribution();
    } catch (e) {
      print('Repository error in getCefrLevelDistribution: $e');
      return {'A1': 0, 'A2': 0, 'B1': 0, 'B2': 0, 'C1': 0, 'C2': 0};
    }
  }

  /// Get total vocabulary count
  /// Returns total number of words learned
  /// Returns zero if error occurs
  Future<int> getTotalVocabularyCount() async {
    try {
      return await _progressService.getTotalVocabularyCount();
    } catch (e) {
      print('Repository error in getTotalVocabularyCount: $e');
      return 0;
    }
  }

  /// Calculate overall progress percentage
  /// Based on total words learned
  Future<double> calculateProgressPercentage() async {
    try {
      final totalWords = await getTotalVocabularyCount();

      // Assuming goal is 1000 words
      const goalWords = 1000;
      final percentage = (totalWords / goalWords * 100).clamp(0.0, 100.0);

      return percentage;
    } catch (e) {
      print('Repository error in calculateProgressPercentage: $e');
      return 0.0;
    }
  }
}
