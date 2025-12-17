import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:magic_enlish/data/models/grammar/grammar.dart';
import 'package:magic_enlish/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GrammarService {
  String get baseUrl => '${ApiConstants.baseUrl}/grammar';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Check grammar with AI
  Future<Grammar> checkGrammar(String text) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/check'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      // Extract data from wrapper: { "data": {...}, "statusCode": 201, ... }
      final data = responseData['data'];
      return Grammar.fromJson(data);
    } else {
      throw Exception('Failed to check grammar: ${response.body}');
    }
  }

  // Get all grammar checks with pagination
  Future<Map<String, dynamic>> getAllGrammarChecks({
    int page = 0,
    int size = 20,
  }) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl?page=$page&size=$size'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      // Extract data from wrapper if exists
      final data = responseData['data'] ?? responseData;
      final result = data['result'] as List<dynamic>;

      return {
        'grammars': result.map((json) => Grammar.fromJson(json)).toList(),
        'meta': data['meta'],
      };
    } else {
      throw Exception('Failed to load grammar checks: ${response.body}');
    }
  }

  // Get grammar check by ID
  Future<Grammar> getGrammarCheckById(int id) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      // Extract data from wrapper if exists
      final data = responseData['data'] ?? responseData;
      return Grammar.fromJson(data);
    } else {
      throw Exception('Failed to load grammar check: ${response.body}');
    }
  }

  // Delete grammar check
  Future<void> deleteGrammarCheck(int id) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete grammar check: ${response.body}');
    }
  }
}
