import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeStatsService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get home statistics
  /// GET /api/v1/vocabulary/home-stats
  Future<Map<String, int>> getHomeStats() async {
    try {
      final String url = dotenv.env['Backend_URL'] ?? '';
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$url/api/v1/vocabulary/home-stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final Map<String, dynamic> data =
            jsonResponse['data'] as Map<String, dynamic>;

        return <String, int>{
          'wordsToday': (data['wordsToday'] as num).toInt(),
          'totalWords': (data['totalWords'] as num).toInt(),
          'streakDays': (data['streakDays'] as num).toInt(),
          'grammarChecks': (data['grammarChecks'] as num).toInt(),
          'totalChecks': (data['totalChecks'] as num).toInt(),
          'avgGrammarScore': (data['avgGrammarScore'] as num).toInt(),
          'avgGrammarScoreTotal': (data['avgGrammarScoreTotal'] as num).toInt(),
          'longestStreak': (data['longestStreak'] as num).toInt(),
        };
      } else {
        return <String, int>{
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
    } catch (e) {
      print('❌ Error fetching home stats: $e');
      return <String, int>{
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
}
