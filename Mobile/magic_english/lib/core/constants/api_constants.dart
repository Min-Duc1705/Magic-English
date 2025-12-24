import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Base URL - reads from .env file
  static String get baseUrl =>
      '${dotenv.env['Backend_URL'] ?? 'http://10.0.2.2:8080'}/api/v1';

  // IELTS endpoints
  static const String ieltsBase = '/ielts';

  // TOEIC endpoints
  static const String toeicBase = '/toeic';
}
