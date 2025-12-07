import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:magic_enlish/data/models/BackendResponse.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VocabularyService {
  /// Get headers with Authorization Bearer token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<BackendResponse<Vocabulary>> addNewWord(Vocabulary vocabulary) async {
    final String url = dotenv.env['Backend_URL'] ?? '';

    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$url/api/v1/vocabulary'),
            headers: headers,
            body: jsonEncode(vocabulary.toJson()),
          )
          .timeout(
            const Duration(seconds: 30), // Tăng timeout lên 30 giây
            onTimeout: () {
              throw Exception(
                'Request timeout - Server đang xử lý lâu, vui lòng thử lại',
              );
            },
          );

      final jsonData = jsonDecode(response.body);

      return BackendResponse<Vocabulary>.fromJson(
        jsonData,
        (data) => Vocabulary.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      print('Error in addNewWord: $e');
      rethrow;
    }
  }

  Future<BackendResponse<List<Vocabulary>>> getAllVocabulary({
    String? search,
    int page = 1,
    int size = 10,
  }) async {
    final String url = dotenv.env['Backend_URL'] ?? '';
    final headers = await _getHeaders();

    // Build URL with pagination and search parameters
    String apiUrl = '$url/api/v1/vocabulary?page=${page - 1}&size=$size';
    if (search != null && search.isNotEmpty) {
      apiUrl += '&search=${Uri.encodeComponent(search)}';
    }

    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    final jsonData = jsonDecode(response.body);

    return BackendResponse<List<Vocabulary>>.fromJson(jsonData, (data) {
      // Backend returns {meta: {...}, result: [...]}
      if (data is Map<String, dynamic> && data['result'] is List) {
        return (data['result'] as List)
            .map((item) => Vocabulary.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    });
  }

  /// Preview vocabulary without saving to database
  /// Used for live preview in add word screen
  Future<BackendResponse<Vocabulary>> previewVocabulary(
    Vocabulary vocabulary,
  ) async {
    final String url = dotenv.env['Backend_URL'] ?? '';
    final headers = await _getHeaders();
    final response = await http
        .post(
          Uri.parse('$url/api/v1/vocabulary/preview'),
          headers: headers,
          body: jsonEncode(vocabulary.toJson()),
        )
        .timeout(
          const Duration(seconds: 30), // Tăng timeout cho preview (AI call)
          onTimeout: () {
            throw Exception(
              'Request timeout - AI đang xử lý lâu, vui lòng thử lại',
            );
          },
        );

    final jsonData = jsonDecode(response.body);

    return BackendResponse<Vocabulary>.fromJson(
      jsonData,
      (data) => Vocabulary.fromJson(data as Map<String, dynamic>),
    );
  }
}
