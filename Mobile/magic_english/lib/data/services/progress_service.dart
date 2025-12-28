import 'dart:convert';
import 'package:magic_enlish/core/utils/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    print(
      '🔐 Stored token: ${token.isEmpty ? "EMPTY!" : token.substring(0, 20)}...',
    );
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get vocabulary breakdown by word type (verb, noun, adjective, adverb)
  /// GET /api/v1/vocabulary/breakdown
  Future<Map<String, int>> getVocabularyBreakdown() async {
    try {
      final String url = dotenv.env['Backend_URL'] ?? '';
      final headers = await _getHeaders();

      print('🔍 Calling: $url/api/v1/vocabulary/breakdown');
      print('🔑 Full Token: ${headers['Authorization']}');

      final response = await ApiClient.get(
        Uri.parse('$url/api/v1/vocabulary/breakdown'),
        headers: headers,
      );

      print('📊 Status: ${response.statusCode}');
      print('📄 Full Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final Map<String, dynamic> jsonData =
            jsonResponse['data'] as Map<String, dynamic>;
        print('✅ Success! Data: $jsonData');
        return jsonData.map(
          (key, value) => MapEntry(key, (value as num).toInt()),
        );
      } else if (response.statusCode == 401) {
        print('❌ 401 UNAUTHORIZED - Token expired or invalid');
        print('❌ Response: ${response.body}');
        return {'verb': 0, 'noun': 0, 'adjective': 0, 'adverb': 0, 'other': 0};
      } else {
        print('❌ API Error ${response.statusCode}: ${response.body}');
        return {'verb': 0, 'noun': 0, 'adjective': 0, 'adverb': 0, 'other': 0};
      }
    } catch (e, stackTrace) {
      print('❌ Exception in getVocabularyBreakdown: $e');
      print('❌ StackTrace: $stackTrace');
      return {'verb': 0, 'noun': 0, 'adjective': 0, 'adverb': 0, 'other': 0};
    }
  }

  /// Get CEFR level distribution (A1-C2)
  /// GET /api/v1/vocabulary/cefr-distribution
  Future<Map<String, int>> getCefrDistribution() async {
    try {
      final String url = dotenv.env['Backend_URL'] ?? '';
      final headers = await _getHeaders();

      final response = await ApiClient.get(
        Uri.parse('$url/api/v1/vocabulary/cefr-distribution'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final Map<String, dynamic> jsonData =
            jsonResponse['data'] as Map<String, dynamic>;
        return jsonData.map(
          (key, value) => MapEntry(key, (value as num).toInt()),
        );
      } else {
        return {'A1': 0, 'A2': 0, 'B1': 0, 'B2': 0, 'C1': 0, 'C2': 0};
      }
    } catch (e) {
      return {'A1': 0, 'A2': 0, 'B1': 0, 'B2': 0, 'C1': 0, 'C2': 0};
    }
  }

  /// Get total vocabulary count
  /// GET /api/v1/vocabulary/count
  Future<int> getTotalVocabularyCount() async {
    try {
      final String url = dotenv.env['Backend_URL'] ?? '';
      final headers = await _getHeaders();

      final response = await ApiClient.get(
        Uri.parse('$url/api/v1/vocabulary/count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] as int;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  /// Get daily vocabulary stats for last N days
  /// GET /api/v1/stats/daily-vocabulary?days=7
  /// Returns list of {date: "2024-12-23", count: 3}
  Future<List<Map<String, dynamic>>> getDailyVocabularyStats({
    int days = 7,
  }) async {
    try {
      final String url = dotenv.env['Backend_URL'] ?? '';
      final headers = await _getHeaders();

      print('📊 Calling: $url/api/v1/stats/daily-vocabulary?days=$days');

      final response = await ApiClient.get(
        Uri.parse('$url/api/v1/stats/daily-vocabulary?days=$days'),
        headers: headers,
      );

      print('📊 Daily Vocabulary Status: ${response.statusCode}');
      print('📊 Daily Vocabulary Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
        print('✅ Daily Vocabulary Data: $data');
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        print('❌ Daily Vocabulary Error: ${response.statusCode}');
        return _generateEmptyDailyStats(days);
      }
    } catch (e) {
      print('❌ Error in getDailyVocabularyStats: $e');
      return _generateEmptyDailyStats(days);
    }
  }

  /// Get daily grammar check stats for last N days
  /// GET /api/v1/stats/daily-grammar-checks?days=7
  Future<List<Map<String, dynamic>>> getDailyGrammarCheckStats({
    int days = 7,
  }) async {
    try {
      final String url = dotenv.env['Backend_URL'] ?? '';
      final headers = await _getHeaders();

      final response = await ApiClient.get(
        Uri.parse('$url/api/v1/stats/daily-grammar-checks?days=$days'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        return _generateEmptyDailyStats(days);
      }
    } catch (e) {
      print('❌ Error in getDailyGrammarCheckStats: $e');
      return _generateEmptyDailyStats(days);
    }
  }

  /// Get daily grammar score stats for last N days
  /// GET /api/v1/stats/daily-grammar-scores?days=7
  Future<List<Map<String, dynamic>>> getDailyGrammarScoreStats({
    int days = 7,
  }) async {
    try {
      final String url = dotenv.env['Backend_URL'] ?? '';
      final headers = await _getHeaders();

      final response = await ApiClient.get(
        Uri.parse('$url/api/v1/stats/daily-grammar-scores?days=$days'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        return _generateEmptyScoreStats(days);
      }
    } catch (e) {
      print('❌ Error in getDailyGrammarScoreStats: $e');
      return _generateEmptyScoreStats(days);
    }
  }

  /// Get daily activity stats for last N days (for streak chart)
  /// GET /api/v1/stats/daily-activity?days=7
  Future<List<Map<String, dynamic>>> getDailyActivityStats({
    int days = 7,
  }) async {
    try {
      final String url = dotenv.env['Backend_URL'] ?? '';
      final headers = await _getHeaders();

      final response = await ApiClient.get(
        Uri.parse('$url/api/v1/stats/daily-activity?days=$days'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        return _generateEmptyActivityStats(days);
      }
    } catch (e) {
      print('❌ Error in getDailyActivityStats: $e');
      return _generateEmptyActivityStats(days);
    }
  }

  /// Generate empty daily stats with count = 0
  List<Map<String, dynamic>> _generateEmptyDailyStats(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final date = now.subtract(Duration(days: days - 1 - i));
      return {
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'count': 0,
      };
    });
  }

  /// Generate empty score stats with avgScore = 0
  List<Map<String, dynamic>> _generateEmptyScoreStats(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final date = now.subtract(Duration(days: days - 1 - i));
      return {
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'avgScore': 0,
      };
    });
  }

  /// Generate empty activity stats with hasActivity = false
  List<Map<String, dynamic>> _generateEmptyActivityStats(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final date = now.subtract(Duration(days: days - 1 - i));
      return {
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'hasActivity': false,
      };
    });
  }
}
