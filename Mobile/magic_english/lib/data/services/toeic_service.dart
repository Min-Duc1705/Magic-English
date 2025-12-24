import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/toeic/toeic_test.dart';
import '../../core/constants/api_constants.dart';

class ToeicService {
  /// Get access token from SharedPreferences
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Get headers with authentication
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found. Please login first.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Generate new test using AI
  Future<ToeicTest> generateTest(String section, String difficulty) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/toeic/generate');
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'section': section, 'difficulty': difficulty}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return ToeicTest.fromJson(data['data']);
    } else {
      throw Exception('Failed to generate TOEIC test: ${response.body}');
    }
  }

  // Get test by ID
  Future<ToeicTest> getTestById(int testId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/toeic/tests/$testId');
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return ToeicTest.fromJson(data['data']);
    } else {
      throw Exception('Failed to get TOEIC test: ${response.body}');
    }
  }

  // Start test session
  Future<ToeicTestHistory> startTest(int testId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/toeic/start');
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'testId': testId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return ToeicTestHistory.fromJson(data['data']);
    } else {
      throw Exception('Failed to start TOEIC test: ${response.body}');
    }
  }

  // Submit test answers
  Future<ToeicTestResult> submitTest(
    int historyId,
    List<Map<String, dynamic>> answers,
    int timeSpentSeconds,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/toeic/submit');
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'historyId': historyId,
        'answers': answers,
        'timeSpentSeconds': timeSpentSeconds,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return ToeicTestResult.fromJson(data['data']);
    } else {
      throw Exception('Failed to submit TOEIC test: ${response.body}');
    }
  }

  // Get user test history
  Future<List<ToeicTestHistory>> getUserHistory() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/toeic/history');
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['data'] as List)
          .map((json) => ToeicTestHistory.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to get TOEIC history: ${response.body}');
    }
  }
}
