import 'package:flutter/material.dart';
import 'package:magic_enlish/data/repositories/home/home_repository.dart';

class HomeStatsProvider with ChangeNotifier {
  final HomeRepository _homeRepository = HomeRepository();

  bool _isLoading = false;
  String? _errorMessage;

  int _streakDays = 0;
  int _wordsToday = 0;
  int _totalWords = 0;
  int _grammarChecks = 0;
  int _totalChecks = 0;
  int _avgGrammarScore = 0;
  int _avgGrammarScoreTotal = 0;
  int _longestStreak = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get streakDays => _streakDays;
  int get wordsToday => _wordsToday;
  int get totalWords => _totalWords;
  int get grammarChecks => _grammarChecks;
  int get totalChecks => _totalChecks;
  int get avgGrammarScore => _avgGrammarScore;
  int get avgGrammarScoreTotal => _avgGrammarScoreTotal;
  int get longestStreak => _longestStreak;

  Future<void> loadHomeStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final stats = await _homeRepository.getHomeStats();
      _streakDays = stats['streakDays'] ?? 0;
      _wordsToday = stats['wordsToday'] ?? 0;
      _totalWords = stats['totalWords'] ?? 0;
      _grammarChecks = stats['grammarChecks'] ?? 0;
      _totalChecks = stats['totalChecks'] ?? 0;
      _avgGrammarScore = stats['avgGrammarScore'] ?? 0;
      _avgGrammarScoreTotal = stats['avgGrammarScoreTotal'] ?? 0;
      _longestStreak = stats['longestStreak'] ?? 0;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStats() async {
    await loadHomeStats();
  }
}
