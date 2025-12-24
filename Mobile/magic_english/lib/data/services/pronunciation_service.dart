import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

/// Model for pronunciation feedback from AI
class PronunciationFeedback {
  final String expectedWord;
  final String transcribedText;
  final int score;
  final String accuracy;
  final String feedback;
  final List<String> suggestions;
  final PhonemeAnalysis? phonemeAnalysis;
  final String? overallAssessment;

  PronunciationFeedback({
    required this.expectedWord,
    required this.transcribedText,
    required this.score,
    required this.accuracy,
    required this.feedback,
    required this.suggestions,
    this.phonemeAnalysis,
    this.overallAssessment,
  });

  factory PronunciationFeedback.fromJson(Map<String, dynamic> json) {
    return PronunciationFeedback(
      expectedWord: json['expectedWord'] ?? '',
      transcribedText: json['transcribedText'] ?? '',
      score: json['score'] ?? 0,
      accuracy: json['accuracy'] ?? 'fair',
      feedback: json['feedback'] ?? '',
      suggestions: json['suggestions'] != null
          ? List<String>.from(json['suggestions'])
          : [],
      phonemeAnalysis: json['phonemeAnalysis'] != null
          ? PhonemeAnalysis.fromJson(json['phonemeAnalysis'])
          : null,
      overallAssessment: json['overallAssessment'],
    );
  }
}

class PhonemeAnalysis {
  final List<String> correctPhonemes;
  final List<String> problematicPhonemes;

  PhonemeAnalysis({
    required this.correctPhonemes,
    required this.problematicPhonemes,
  });

  factory PhonemeAnalysis.fromJson(Map<String, dynamic> json) {
    return PhonemeAnalysis(
      correctPhonemes: json['correctPhonemes'] != null
          ? List<String>.from(json['correctPhonemes'])
          : [],
      problematicPhonemes: json['problematicPhonemes'] != null
          ? List<String>.from(json['problematicPhonemes'])
          : [],
    );
  }
}

/// Service for AI-powered pronunciation assessment
class PronunciationService {
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

  /// Analyze pronunciation using AI
  ///
  /// [expectedWord] - The word the user was supposed to say
  /// [transcribedText] - The text transcribed from user's speech
  /// [ipa] - Optional IPA pronunciation of the expected word
  Future<PronunciationFeedback> analyzePronunciation({
    required String expectedWord,
    required String transcribedText,
    String? ipa,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/pronunciation/analyze');
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'expectedWord': expectedWord,
        'transcribedText': transcribedText,
        'ipa': ipa,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      // Handle both wrapped and unwrapped responses
      final feedbackData = data['data'] ?? data;
      return PronunciationFeedback.fromJson(feedbackData);
    } else {
      throw Exception('Failed to analyze pronunciation: ${response.body}');
    }
  }
}
