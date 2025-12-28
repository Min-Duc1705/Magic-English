import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:magic_enlish/core/utils/navigator_key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    return _sendRequest((h) => http.get(url, headers: h), headers);
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _sendRequest((h) => http.post(url, headers: h, body: body), headers);
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _sendRequest((h) => http.put(url, headers: h, body: body), headers);
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _sendRequest(
      (h) => http.delete(url, headers: h, body: body),
      headers,
    );
  }

  // Wrapper to handle 401 and Refresh Token
  static Future<http.Response> _sendRequest(
    Future<http.Response> Function(Map<String, String>? headers) requestFunc,
    Map<String, String>? originalHeaders,
  ) async {
    // 1. Initial Request
    final response = await requestFunc(originalHeaders);

    // 2. Check 401 Unauthorized
    if (response.statusCode == 401) {
      print('⚠️ 401 Detected. Attempting Refresh Token...');
      // 3. Try to Refresh Token
      final bool refreshSuccess = await _refreshToken();

      if (refreshSuccess) {
        print('✅ Refresh Token Success. Retrying request...');
        // 4. Update Headers with new Access Token
        final prefs = await SharedPreferences.getInstance();
        final newToken = prefs.getString('access_token');
        final newHeaders = Map<String, String>.from(originalHeaders ?? {});
        if (newToken != null) {
          newHeaders['Authorization'] = 'Bearer $newToken';
        }

        // 5. Retry Request
        return await requestFunc(newHeaders);
      } else {
        print('❌ Refresh Token Failed. Logging out...');
        // 6. Logout if refresh failed
        await _logout();
      }
    }

    return response;
  }

  // Call Backend to refresh token
  static Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ No refresh token found in storage.');
        return false;
      }

      final String baseUrl = dotenv.env['Backend_URL'] ?? '';
      final refreshUrl = Uri.parse('$baseUrl/api/v1/auth/refresh');

      // Backend expects refresh_token in Cookie
      print(
        'ℹ️ Sending Refresh Token (Length: ${refreshToken.length}): ...${refreshToken.substring(refreshToken.length - 10)}',
      );
      final response = await http.get(
        refreshUrl,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'refresh_token=$refreshToken',
        },
      );

      if (response.statusCode == 200) {
        print('--------------------------------------------------');
        print('✅ REFRESH TOKEN SUCCESS!');
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data']; // Extract DTO from wrapper

        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        if (newAccessToken != null && newAccessToken.length > 10) {
          print(
            '🔑 New Access Token: ...${newAccessToken.substring(newAccessToken.length - 10)}',
          );
        } else {
          print('🔑 New Access Token: $newAccessToken');
        }

        if (newRefreshToken != null && newRefreshToken.length > 10) {
          print(
            '🔄 New Refresh Token: ...${newRefreshToken.substring(newRefreshToken.length - 10)}',
          );
        } else {
          print('🔄 New Refresh Token: $newRefreshToken');
        }

        if (newAccessToken != null) {
          await prefs.setString('access_token', newAccessToken);
        }
        if (newRefreshToken != null) {
          await prefs.setString('refresh_token', newRefreshToken);
        }
        print('--------------------------------------------------');
        return true;
      } else {
        print('--------------------------------------------------');
        print('❌ REFRESH TOKEN FAILED');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('--------------------------------------------------');
        return false;
      }
    } catch (e) {
      print('❌ Exception during refresh token: $e');
      return false;
    }
  }

  // Clear session and redirect to login
  static Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }
}
