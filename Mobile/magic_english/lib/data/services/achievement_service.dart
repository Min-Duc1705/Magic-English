import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/progress/achievement.dart';
import '../models/progress/user_achievement.dart';

class AchievementService {
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Check and grant achievements
  /// Returns list of newly unlocked achievements
  Future<List<Achievement>> checkAchievement(
    String metricType,
    int currentValue,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/user-achievements/check');
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'metricType': metricType,
        'currentValue': currentValue,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print('Achievement API Response: $jsonResponse'); // Debug log

      // Response format chuẩn:
      // { statusCode: 200, message: "SUCCESS", data: [achievements] }
      final achievementsData = jsonResponse['data'];
      print(
        'Achievements data type: ${achievementsData?.runtimeType}, value: $achievementsData',
      );

      if (achievementsData != null) {
        // Handle if data is a List (multiple achievements or empty list)
        if (achievementsData is List) {
          if (achievementsData.isEmpty) {
            print('Empty achievements list');
            return [];
          }
          print('Parsing ${achievementsData.length} achievements');
          final achievements = achievementsData
              .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
              .toList();
          print('Parsed ${achievements.length} achievements');
          return achievements;
        }
        // Handle if data is a Map (single achievement)
        else if (achievementsData is Map<String, dynamic>) {
          print('Parsing as single Map');
          final achievement = Achievement.fromJson(achievementsData);
          print('Parsed achievement: ${achievement.title}');
          return [achievement];
        }
      }
      print('No achievements data to parse, returning empty list');
      return [];
    } else {
      print('Failed to check achievement: ${response.body}');
      return [];
    }
  }

  /// Get all achievements unlocked by the current user
  Future<List<UserAchievement>> getUserAchievements() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/user-achievements');
    final headers = await _getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final data = jsonResponse['data'];

        if (data != null && data is List) {
          return data
              .map(
                (json) =>
                    UserAchievement.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching user achievements: $e');
      return [];
    }
  }

  /// Get all achievements in the system (for showing locked/unlocked status)
  Future<List<Achievement>> getAllAchievements() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/user-achievements/all');
    final headers = await _getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final data = jsonResponse['data'];

        if (data != null && data is List) {
          return data
              .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching all achievements: $e');
      return [];
    }
  }
}
