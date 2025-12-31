import 'dart:convert';
import 'package:http/http.dart' as http;
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

      final response = await http.get(
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

      final response = await http.get(
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

      final response = await http.get(
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
}
