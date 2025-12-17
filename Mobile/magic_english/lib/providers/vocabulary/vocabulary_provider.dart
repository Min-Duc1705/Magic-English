import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';
import 'package:magic_enlish/data/repositories/vocabulary/vocabulary_repository.dart';
import 'package:magic_enlish/data/services/achievement_service.dart';
import 'package:magic_enlish/core/widgets/common/achievement_dialog.dart';

class VocabularyProvider with ChangeNotifier {
  final VocabularyRepository _vocabularyRepository = VocabularyRepository();

  List<Vocabulary> _vocabularies = [];
  List<Vocabulary> _filteredVocabularies = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _selectedFilter = 'All';
  Set<int> _favoriteIds = {};

  // Pagination state
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String? _currentSearch;

  List<Vocabulary> get vocabularies => _filteredVocabularies;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get selectedFilter => _selectedFilter;

  VocabularyProvider() {
    _loadFavorites();
    loadVocabularies();
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList =
          prefs.getStringList('favorite_vocabulary_ids') ?? [];
      _favoriteIds = favoritesList.map((id) => int.parse(id)).toSet();
      notifyListeners();
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = _favoriteIds.map((id) => id.toString()).toList();
      await prefs.setStringList('favorite_vocabulary_ids', favoritesList);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  Future<void> loadVocabularies({String? search, bool reset = true}) async {
    if (reset) {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
      _vocabularies = [];
    }

    _currentSearch = search;
    _error = null;
    notifyListeners();

    try {
      final List<Vocabulary> vocabularies = await _vocabularyRepository
          .getAllVocabulary(
            search: search,
            page: _currentPage,
            size: _pageSize,
          );

      if (reset) {
        _vocabularies = vocabularies;
      } else {
        _vocabularies.addAll(vocabularies);
      }

      // Check if there are more pages
      _hasMore = vocabularies.length >= _pageSize;

      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreVocabularies() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final List<Vocabulary> vocabularies = await _vocabularyRepository
          .getAllVocabulary(
            search: _currentSearch,
            page: _currentPage,
            size: _pageSize,
          );

      _vocabularies.addAll(vocabularies);

      // Check if there are more pages
      _hasMore = vocabularies.length >= _pageSize;

      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> addVocabulary(
    Vocabulary vocabulary,
    BuildContext? context,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Vocabulary newVocab = await _vocabularyRepository.addNewWord(
        vocabulary,
      );
      _vocabularies.add(newVocab);
      _applyFilter();

      // Check for achievements
      if (context != null && context.mounted) {
        try {
          print(
            '🔔 [Flutter] Calling checkAchievement with vocab count: ${_vocabularies.length}',
          );
          final achievementService = AchievementService();
          // 'vocab_added' is the metric, current value is total list size
          final newAchievements = await achievementService.checkAchievement(
            'vocab_added',
            _vocabularies.length,
          );
          print('🔔 [Flutter] Received ${newAchievements.length} achievements');

          if (newAchievements.isNotEmpty && context.mounted) {
            // Show the first one (or loop if multiple)
            print(
              '🎉 [Flutter] Showing achievement dialog: ${newAchievements.first.title}',
            );
            AchievementDialog.show(context, newAchievements.first);
          }
        } catch (e) {
          print('Achievement check failed: $e');
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchVocabularies(String query) async {
    // Reset pagination when search changes
    await loadVocabularies(search: query.isEmpty ? null : query, reset: true);
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilter();
  }

  void _applyFilter() {
    switch (_selectedFilter) {
      case 'All':
        _filteredVocabularies = List.from(_vocabularies);
        break;
      case 'A1-A2':
        _filteredVocabularies = _vocabularies
            .where((v) => v.cefrLevel == 'A1' || v.cefrLevel == 'A2')
            .toList();
        break;
      case 'B1-B2':
        _filteredVocabularies = _vocabularies
            .where((v) => v.cefrLevel == 'B1' || v.cefrLevel == 'B2')
            .toList();
        break;
      case 'C1-C2':
        _filteredVocabularies = _vocabularies
            .where((v) => v.cefrLevel == 'C1' || v.cefrLevel == 'C2')
            .toList();
        break;
      case 'Favorites':
        _filteredVocabularies = _vocabularies
            .where((v) => v.id != null && _favoriteIds.contains(v.id))
            .toList();
        break;
      default:
        _filteredVocabularies = List.from(_vocabularies);
    }
    notifyListeners();
  }

  void toggleFavorite(int vocabularyId) {
    if (_favoriteIds.contains(vocabularyId)) {
      _favoriteIds.remove(vocabularyId);
    } else {
      _favoriteIds.add(vocabularyId);
    }

    // Save to SharedPreferences
    _saveFavorites();

    if (_selectedFilter == 'Favorites') {
      _applyFilter();
    } else {
      notifyListeners();
    }
  }

  bool isFavorite(int? vocabularyId) {
    return vocabularyId != null && _favoriteIds.contains(vocabularyId);
  }
}
