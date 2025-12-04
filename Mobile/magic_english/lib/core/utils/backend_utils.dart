import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Utility class for backend/environment related helpers
class BackendUtils {
  /// Check if running with local backend (localhost, 10.0.2.2, or 127.0.0.1)
  static bool isLocalBackend() {
    final backendUrl = dotenv.env['Backend_URL'] ?? '';
    return backendUrl.contains('localhost') ||
        backendUrl.contains('10.0.2.2') ||
        backendUrl.contains('127.0.0.1');
  }

  /// Get image URL based on environment
  /// If local: uses backend storage URL
  /// If production: uses cloudinaryUrl
  static String getImageUrl({
    required String localPath,
    required String cloudinaryUrl,
  }) {
    if (isLocalBackend()) {
      final backendUrl = dotenv.env['Backend_URL'] ?? '';
      return '$backendUrl$localPath';
    }
    return cloudinaryUrl;
  }

  /// Get full URL for audio/API endpoints
  /// Handles both relative paths (/api/...) and full URLs (http://...)
  static String getFullUrl(String url) {
    if (url.isEmpty) return url;

    // If already a full URL, return as-is
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // For relative URLs, prepend backend URL
    final backendUrl = dotenv.env['Backend_URL'] ?? '';
    return '$backendUrl$url';
  }
}
