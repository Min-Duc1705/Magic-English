import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:magic_enlish/data/models/ielts/ielts_test.dart';
import 'package:magic_enlish/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IELTSService {
  final String baseUrl = '${ApiConstants.baseUrl}/ielts';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Generate a new IELTS test using AI
  Future<IELTSTest> generateTest({
    required String skill,
    required String level,
    required String difficulty,
  }) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'skill': skill,
        'level': level,
        'difficulty': difficulty,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final data = responseData['data'];
      return IELTSTest.fromJson(data);
    } else {
      throw Exception('Failed to generate test: ${response.body}');
    }
  }

  /// Get test details by ID
  Future<IELTSTest> getTestById(int testId) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/tests/$testId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final data = responseData['data'];
      return IELTSTest.fromJson(data);
    } else {
      throw Exception('Failed to fetch test: ${response.body}');
    }
  }

  /// Start a test session
  Future<IELTSTestHistory> startTest(int testId) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'testId': testId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final data = responseData['data'];
      return IELTSTestHistory.fromJson(data);
    } else {
      throw Exception('Failed to start test: ${response.body}');
    }
  }

  /// Submit test answers
  Future<IELTSTestResult> submitTest({
    required int historyId,
    required List<Map<String, dynamic>> answers,
    required int timeSpentSeconds,
  }) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'historyId': historyId,
        'answers': answers,
        'timeSpentSeconds': timeSpentSeconds,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final data = responseData['data'];
      return IELTSTestResult.fromJson(data);
    } else {
      throw Exception('Failed to submit test: ${response.body}');
    }
  }

  /// Get user's test history
  Future<List<IELTSTestHistory>> getUserHistory() async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> data = responseData['data'];
      return data.map((json) => IELTSTestHistory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch history: ${response.body}');
    }
  }
}
