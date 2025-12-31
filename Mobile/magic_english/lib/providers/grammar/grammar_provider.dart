import 'package:flutter/material.dart';
import 'package:magic_enlish/data/models/grammar/grammar.dart';
import 'package:magic_enlish/data/repositories/grammar/grammar_repository.dart';

class GrammarProvider with ChangeNotifier {
  final GrammarRepository _grammarRepository = GrammarRepository();

  Grammar? _currentGrammar;
  List<Grammar> _grammarHistory = [];
  bool _isLoading = false;
  String? _error;

  // Pagination
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  Grammar? get currentGrammar => _currentGrammar;
  List<Grammar> get grammarHistory => _grammarHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Check grammar
  Future<void> checkGrammar(String text) async {
    if (text.trim().isEmpty) {
      _error = 'Please enter some text to check';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentGrammar = await _grammarRepository.checkGrammar(text);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentGrammar = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load grammar history
  Future<void> loadGrammarHistory({bool reset = false}) async {
    if (reset) {
      _currentPage = 0;
      _grammarHistory = [];
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _grammarRepository.getAllGrammarChecks(
        page: _currentPage,
        size: _pageSize,
      );

      final List<Grammar> newGrammars = response['grammars'];
      final meta = response['meta'];

      if (reset) {
        _grammarHistory = newGrammars;
      } else {
        _grammarHistory.addAll(newGrammars);
      }

      _currentPage++;
      _hasMore = _currentPage < (meta['pages'] ?? 0);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more history items
  Future<void> loadMoreHistory() async {
    if (!_isLoading && _hasMore) {
      await loadGrammarHistory();
    }
  }

  // Get grammar by ID
  Future<void> getGrammarById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentGrammar = await _grammarRepository.getGrammarCheckById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete grammar check
  Future<bool> deleteGrammarCheck(int id) async {
    try {
      await _grammarRepository.deleteGrammarCheck(id);
      _grammarHistory.removeWhere((g) => g.id == id);
      if (_currentGrammar?.id == id) {
        _currentGrammar = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear current grammar result
  void clearCurrentGrammar() {
    _currentGrammar = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
