import 'package:magic_enlish/data/models/grammar/grammar.dart';
import 'package:magic_enlish/data/services/grammar_service.dart';

class GrammarRepository {
  final GrammarService _grammarService;

  GrammarRepository({GrammarService? grammarService})
    : _grammarService = grammarService ?? GrammarService();

  /// Check grammar for given text
  /// Returns Grammar object with corrections and analysis
  /// Throws Exception if check fails
  Future<Grammar> checkGrammar(String text) async {
    try {
      if (text.trim().isEmpty) {
        throw Exception('Text cannot be empty');
      }

      return await _grammarService.checkGrammar(text);
    } catch (e) {
      if (e.toString().contains('No access token')) {
        throw Exception('Please login to use grammar checker');
      }
      throw Exception('Grammar check error: ${e.toString()}');
    }
  }

  /// Get all grammar checks with pagination
  /// Returns map with grammar checks list and metadata
  /// Throws Exception if fetching fails
  Future<Map<String, dynamic>> getAllGrammarChecks({
    int page = 0,
    int size = 20,
  }) async {
    try {
      return await _grammarService.getAllGrammarChecks(page: page, size: size);
    } catch (e) {
      throw Exception('Fetch grammar checks error: ${e.toString()}');
    }
  }

  /// Get grammar check by ID
  /// Returns Grammar object
  /// Throws Exception if fetching fails
  Future<Grammar> getGrammarCheckById(int id) async {
    try {
      return await _grammarService.getGrammarCheckById(id);
    } catch (e) {
      throw Exception('Fetch grammar check error: ${e.toString()}');
    }
  }

  /// Delete grammar check by ID
  /// Throws Exception if deletion fails
  Future<void> deleteGrammarCheck(int id) async {
    try {
      await _grammarService.deleteGrammarCheck(id);
    } catch (e) {
      throw Exception('Delete grammar check error: ${e.toString()}');
    }
  }
}
